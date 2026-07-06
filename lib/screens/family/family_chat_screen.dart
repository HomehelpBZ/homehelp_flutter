import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
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

  final List<Map<String, dynamic>> _messages = [
    {'text': "Hello! We're a family of 5 looking for a full-time housekeeper.", 'isMe': true, 'time': '10:02 AM'},
    {'text': 'Hello! Thank you so much. Yes, I am still available. I would love to learn more!', 'isMe': false, 'time': '10:15 AM'},
    {'text': "We'd like to offer you the job. Can you start June 1st at 4,500 Birr per month?", 'isMe': true, 'time': '11:30 AM'},
    {'text': 'Yes! I accept. June 1st works perfectly. Thank you so much!', 'isMe': false, 'time': '11:35 AM'},
  ];

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': _controller.text.trim(), 'isMe': true, 'time': 'Just now'});
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
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
            const Text('Online', style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 11)),
          ]),
        ]),
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
                              style: TextStyle(fontSize: 12,
                                  color: isMe ? Colors.white : AppTheme.grey800, height: 1.5)),
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
          // Hire banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.primaryLight,
            child: Row(children: [
              Expanded(
                child: Text('Ready to hire $firstName? ${s.confirmHire}',
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
            ]),
          ),
        ],
      ),
    );
  }
}
