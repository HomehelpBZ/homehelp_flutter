import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'hk_messages_screen.dart';
import 'hk_profile_screen.dart';
import 'hk_edit_profile_screen.dart';
import 'hk_settings_screen.dart';
import 'job_board_screen.dart';

class HkDashboardScreen extends StatefulWidget {
  const HkDashboardScreen({super.key});

  @override
  State<HkDashboardScreen> createState() => _HkDashboardScreenState();
}

class _HkDashboardScreenState extends State<HkDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Navy hero header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 18),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Lang toggle row
                  Align(alignment: Alignment.topRight, child: const LangToggleButton()),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Text('TK',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tigist Bekele',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          const Text('Full-time housekeeper · Bole',
                              style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(s.profileLive,
                                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _Stat('24', s.views),
                        _Stat('3', s.messages),
                        _Stat('4.9', s.rating),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(s.quickActions),
                  _ActionCard(
                    icon: Icons.work_outline,
                    iconBg: const Color(0xFFE6F1FB),
                    iconColor: const Color(0xFF185FA5),
                    title: s.jobBoard,
                    subtitle: s.jobsTab,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const JobBoardScreen())),
                  ),
                  _ActionCard(
                    icon: Icons.edit_outlined,
                    iconBg: AppTheme.primaryLight,
                    iconColor: AppTheme.primary,
                    title: s.editMyProfile,
                    subtitle: s.editProfileSub,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HkEditProfileScreen())),
                  ),
                  _ActionCard(
                    icon: Icons.message_outlined,
                    iconBg: AppTheme.amberLight,
                    iconColor: AppTheme.amber,
                    title: s.messagesLabel,
                    subtitle: s.messagesSub,
                    badge: '3',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HkMessagesScreen())),
                  ),
                  _ActionCard(
                    icon: Icons.person_outlined,
                    iconBg: const Color(0xFFEEEDFE),
                    iconColor: const Color(0xFF534AB7),
                    title: s.myProfile,
                    subtitle: s.myProfileSub,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HkProfileScreen())),
                  ),
                  _ActionCard(
                    icon: Icons.visibility_outlined,
                    iconBg: const Color(0xFFE6F1FB),
                    iconColor: const Color(0xFF185FA5),
                    title: s.previewProfile,
                    subtitle: s.previewProfileSub,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.notifications),
                  ...[
                    (s.notif1, s.notifTime1, true),
                    (s.notif2, s.notifTime2, true),
                    (s.notif3, s.notifTime3, false),
                  ].map((n) => _NotifRow(
                        text: n.$1,
                        time: n.$2,
                        isUnread: n.$3,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) {
          setState(() => _tab = i);
          if (i == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (i == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const JobBoardScreen()));
          } else if (i == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HkMessagesScreen()));
          } else if (i == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HkProfileScreen()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: s.home),
          BottomNavigationBarItem(icon: const Icon(Icons.work_outline), label: s.jobsTab),
          BottomNavigationBarItem(icon: const Icon(Icons.message_outlined), label: s.messages),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outlined), label: s.profileTab),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle, this.badge, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right, color: AppTheme.grey400, size: 18),
          ],
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final String text;
  final String time;
  final bool isUnread;
  const _NotifRow({required this.text, required this.time, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: isUnread ? AppTheme.primary : AppTheme.grey200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.grey800)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
