import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';

class HkMessagesScreen extends StatelessWidget {
  const HkMessagesScreen({super.key});

  static const _messages = [
    ('KF', 'The Kebede Family', 'Hi Tigist! We saw your profile…', '2h ago', 2, Color(0xFFD85A30)),
    ('GH', 'Ato Girma Household', 'Are you available Thursday?', '5h ago', 1, Color(0xFF534AB7)),
    ('AH', 'Almaz Household', 'Thank you for getting back…', 'Yesterday', 1, AppTheme.primary),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navyAppBar('Messages'),
      body: ListView.separated(
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const Divider(height: 0, color: Color(0xFFEEEEEE)),
        itemBuilder: (context, i) {
          final msg = _messages[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => HkChatScreen(familyName: msg.$2))),
            leading: CircleAvatar(
              backgroundColor: msg.$6,
              child: Text(msg.$1,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            title: Text(msg.$2,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
            subtitle: Text(msg.$3,
                style: const TextStyle(fontSize: 12, color: AppTheme.grey600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(msg.$4, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                const SizedBox(height: 4),
                Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${msg.$5}',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
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
  const HkChatScreen({super.key, required this.familyName});

  @override
  State<HkChatScreen> createState() => _HkChatScreenState();
}

class _HkChatScreenState extends State<HkChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'text': "Hello Tigist! We saw your profile on HomeHelp and we're very impressed.", 'isMe': false, 'time': '10:02 AM'},
    {'text': 'Hello! Thank you so much. I am still available and would love to learn more!', 'isMe': true, 'time': '10:15 AM'},
    {'text': 'Would you be available for an interview this Thursday at 10am in Bole?', 'isMe': false, 'time': '10:18 AM'},
    {'text': 'Yes, Thursday at 10am works perfectly. Please send me the address.', 'isMe': true, 'time': '10:20 AM'},
  ];

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': _controller.text.trim(), 'isMe': true, 'time': 'Just now'});
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
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
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: const [LangToggleButton()],
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(widget.familyName.substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.familyName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Text('Bole · Online',
                    style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isMe = msg['isMe'] as bool;
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
                          child: Text(msg['text'] as String,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isMe ? Colors.white : AppTheme.grey800,
                                  height: 1.5)),
                        ),
                        const SizedBox(height: 3),
                        Text(msg['time'] as String,
                            style: const TextStyle(fontSize: 10, color: AppTheme.grey400)),
                      ],
                    ),
                  ),
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
                      hintText: 'Type a message…',
                      hintStyle: const TextStyle(color: AppTheme.grey400),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 16),
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
