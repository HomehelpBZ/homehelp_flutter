import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import 'family_chat_screen.dart';

class FamilyMessagesScreen extends StatelessWidget {
  const FamilyMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);

    // Sample conversations — in real app from backend
    final conversations = [
      (sampleHousekeepers[0], 'Yes, Thursday at 10am works perfectly!', '11:35 AM', 1),
      (sampleHousekeepers[1], 'Hello! Thank you for reaching out.', '9:02 AM', 0),
      (sampleHousekeepers[2], 'I am available starting June 1st.', 'Yesterday', 2),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 14),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.topRight, child: const LangToggleButton()),
                  const SizedBox(height: 6),
                  Text(s.messages,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(s.familiesInterested,
                      style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.message_outlined, size: 44, color: AppTheme.grey200),
                        const SizedBox(height: 14),
                        Text(s.messages,
                            style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, i) {
                      final conv = conversations[i];
                      final hk = conv.$1;
                      final lastMsg = conv.$2;
                      final time = conv.$3;
                      final unread = conv.$4;

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FamilyChatScreen(hk: hk)),
                        ),
                        leading: HkAvatar(initials: hk.initials, color: AppTheme.primary),
                        title: Text(hk.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.grey800)),
                        subtitle: Text(lastMsg,
                            style: const TextStyle(fontSize: 12, color: AppTheme.grey600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(time,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.grey400)),
                            const SizedBox(height: 4),
                            if (unread > 0)
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text('$unread',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ),
                              )
                            else
                              const SizedBox(width: 18, height: 18),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
