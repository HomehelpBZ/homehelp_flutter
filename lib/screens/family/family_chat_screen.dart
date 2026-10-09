import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import '../../services/user_service.dart';
import 'review_flow_screen.dart';

class FamilyChatScreen extends StatefulWidget {
  final Housekeeper hk;
  const FamilyChatScreen({super.key, required this.hk});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _svc = UserService();
  bool _sending = false;

  String get _familyUid => FirebaseAuth.instance.currentUser?.uid ?? '';

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
        familyUid: _familyUid,
        hkUid: widget.hk.id,
        senderUid: _familyUid,
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
    final firstName = widget.hk.name.split(' ').first;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: const [LangToggleButton()],
        title: Row(children: [
          HkAvatar(initials: widget.hk.initials,
              color: Colors.white.withOpacity(0.25), size: 36, fontSize: 12),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.hk.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Text('HomeHelp', style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11)),
          ]),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _svc.getMessages(_familyUid, widget.hk.id),
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
                    final isMe = data['senderUid'] == _familyUid;
                    final text = data['text'] as String? ?? '';
                    final time = _formatTime(data['sentAt'] as Timestamp?);
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                                      color: isMe ? Colors.white : AppTheme.grey800, height: 1.5)),
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
          // Hire banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.primaryLight,
            child: Row(children: [
              Expanded(
                child: Text('${s.readyToHire} $firstName?',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryText, height: 1.4)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ReviewFlowScreen(hk: widget.hk))),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                  minimumSize: Size.zero,
                ),
                child: Text(s.yes),
              ),
            ]),
          ),
          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: s.typeMessage,
                    hintStyle: const TextStyle(color: AppTheme.grey400),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white, size: 16),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
