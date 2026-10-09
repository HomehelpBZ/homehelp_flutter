import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/user_service.dart';

class HkMessagesScreen extends StatefulWidget {
  const HkMessagesScreen({super.key});

  @override
  State<HkMessagesScreen> createState() => _HkMessagesScreenState();
}

class _HkMessagesScreenState extends State<HkMessagesScreen> {
  final _svc = UserService();
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    final chats = await _svc.getHkChats(uid);
    if (mounted) setState(() { _chats = chats; _loading = false; });
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      appBar: navyAppBar(s.messages),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.message_outlined, size: 44, color: AppTheme.grey200),
                      const SizedBox(height: 14),
                      Text(s.noMessages,
                          style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _chats.length,
                  separatorBuilder: (_, __) => const Divider(height: 0, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, i) {
                    final chat = _chats[i];
                    final familyName = chat['familyName'] as String? ?? 'Family';
                    final familyUid = chat['familyUid'] as String? ?? '';
                    final lastMsg = chat['lastMessage'] as String? ?? '';
                    final unread = (chat['hkUnread'] as num?)?.toInt() ?? 0;
                    final time = _formatTime(chat['lastMessageAt']);
                    final initials = familyName.split(' ')
                        .where((w) => w.isNotEmpty).take(2)
                        .map((w) => w[0].toUpperCase()).join();
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      onTap: () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                        await _svc.markChatRead(familyUid, uid, false);
                        if (context.mounted) {
                          await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => HkChatScreen(
                                      familyName: familyName, familyUid: familyUid)));
                          _load();
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      title: Text(familyName,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                      subtitle: Text(lastMsg,
                          style: const TextStyle(fontSize: 12, color: AppTheme.grey600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                          const SizedBox(height: 4),
                          if (unread > 0)
                            Container(
                              width: 18, height: 18,
                              decoration: const BoxDecoration(
                                  color: AppTheme.primary, shape: BoxShape.circle),
                              child: Center(
                                child: Text('$unread',
                                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            )
                          else
                            const SizedBox(width: 18, height: 18),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class HkChatScreen extends StatefulWidget {
  final String familyName;
  final String familyUid;
  const HkChatScreen({super.key, required this.familyName, required this.familyUid});

  @override
  State<HkChatScreen> createState() => _HkChatScreenState();
}

class _HkChatScreenState extends State<HkChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _svc = UserService();
  bool _sending = false;

  String get _hkUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _svc.sendMessage(
        familyUid: widget.familyUid,
        hkUid: _hkUid,
        senderUid: _hkUid,
        text: text,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final initials = widget.familyName.split(' ')
        .where((w) => w.isNotEmpty).take(2)
        .map((w) => w[0].toUpperCase()).join();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: const [LangToggleButton()],
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.familyName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Text('HomeHelp',
                    style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _svc.getMessages(widget.familyUid, _hkUid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(s.noMessages,
                        style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final isMe = data['senderUid'] == _hkUid;
                    final text = data['text'] as String? ?? '';
                    final time = _formatTime(data['sentAt'] as Timestamp?);
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: isMe ? AppTheme.primary : const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(isMe ? 14 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 14),
                                ),
                              ),
                              child: Text(text,
                                  style: TextStyle(fontSize: 12,
                                      color: isMe ? Colors.white : AppTheme.grey800,
                                      height: 1.5)),
                            ),
                            const SizedBox(height: 3),
                            Text(time,
                                style: const TextStyle(fontSize: 10, color: AppTheme.grey400)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: s.typeMessage,
                      hintStyle: const TextStyle(color: AppTheme.grey400),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                        color: AppTheme.primary, shape: BoxShape.circle),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}