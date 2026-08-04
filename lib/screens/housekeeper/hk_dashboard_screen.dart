import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/job.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hk_messages_screen.dart';
import 'hk_profile_screen.dart';
import 'hk_settings_screen.dart';
import 'job_board_screen.dart';
import '../welcome_screen.dart';

class HkDashboardScreen extends StatefulWidget {
  const HkDashboardScreen({super.key});

  @override
  State<HkDashboardScreen> createState() => _HkDashboardScreenState();
}

class _HkDashboardScreenState extends State<HkDashboardScreen> {
  int _tab = 0;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final Set<String> _expressedInterest = {};
  Map<String, dynamic>? _hkProfile;
  bool _profileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await _userService.getHkProfile(uid);
      if (mounted) {
        setState(() {
          _hkProfile = profile;
          _profileLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (r) => false,
                );
              }
            },
            child: const Text('Sign out'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    // Show 3 most recent jobs on dashboard
    final recentJobs = sampleJobs.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const LangToggleButton(),
                      GestureDetector(
                        onTap: _signOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            const Icon(Icons.logout,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(s.settingsSignOut,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Profile row
                  _profileLoading
                      ? const SizedBox(height: 56)
                      : Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _getInitials(_hkProfile?['fullName'] ?? ''),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hkProfile?['fullName'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                            const SizedBox(height: 3),
                            _StatusBadge(
                                status: _hkProfile?['verificationStatus'] ?? 'pending_guarantor'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats
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
                  // Jobs near you
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.jobBoard,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.grey800)),
                      TextButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const JobBoardScreen())),
                        style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero),
                        child: Text(s.seeAll,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Recent job cards
                  ...recentJobs.map((job) => _JobPreviewCard(
                        job: job,
                        hasExpressedInterest:
                            _expressedInterest.contains(job.id),
                        onExpressInterest: () {
                          setState(
                              () => _expressedInterest.add(job.id));
                          showSuccessToast(context, s.interestExpressed);
                        },
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => JobDetailScreen(
                                      job: job,
                                      hasExpressedInterest:
                                          _expressedInterest
                                              .contains(job.id),
                                      onExpressInterest: () => setState(
                                          () => _expressedInterest
                                              .add(job.id)),
                                    ))),
                      )),

                  const SizedBox(height: 16),

                  // Notifications
                  Text(s.notifications,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.grey800)),
                  const SizedBox(height: 8),
                  ...[
                    (s.notif1, s.notifTime1, true),
                    (s.notif2, s.notifTime2, true),
                    (s.notif3, s.notifTime3, false),
                  ].map((n) => _NotifRow(
                        text: n.$1,
                        time: n.$2,
                        isUnread: n.$3,
                      )),
                  const SizedBox(height: 16),
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
          if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JobBoardScreen()));
          } else if (i == 2) {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const HkMessagesScreen()));
          } else if (i == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HkProfileScreen()));
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined), label: s.home),
          BottomNavigationBarItem(
              icon: const Icon(Icons.work_outline), label: s.jobsTab),
          BottomNavigationBarItem(
              icon: const Icon(Icons.message_outlined), label: s.messages),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined), label: s.profileTab),
        ],
      ),
    );
  }
}

// ── Job preview card ──────────────────────────────────────────────────────────
class _JobPreviewCard extends StatelessWidget {
  final Job job;
  final bool hasExpressedInterest;
  final VoidCallback onExpressInterest;
  final VoidCallback onTap;

  const _JobPreviewCard({
    required this.job,
    required this.hasExpressedInterest,
    required this.onExpressInterest,
    required this.onTap,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.grey200, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(job.jobType,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.grey800)),
                ),
                Text('${job.salary.toStringAsFixed(0)} ${s.birr}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
                '${job.familyLastName} ${s.familySuffix} · ${job.area} · ${job.arrangement}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.grey600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.access_time,
                      size: 12, color: AppTheme.grey400),
                  const SizedBox(width: 4),
                  Text(job.postedAgo,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.grey400)),
                ]),
                hasExpressedInterest
                    ? Row(children: [
                        const Icon(Icons.check_circle,
                            size: 13, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(s.alreadyExpressedInterest,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500)),
                      ])
                    : GestureDetector(
                        onTap: onExpressInterest,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s.expressInterest,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        icon = Icons.check_circle;
        label = 'Profile live';
        break;
      case 'rejected':
        bg = AppTheme.redLight;
        fg = AppTheme.red;
        icon = Icons.cancel;
        label = 'Profile rejected';
        break;
      case 'pending_review':
        bg = AppTheme.amberLight;
        fg = AppTheme.amber;
        icon = Icons.access_time;
        label = 'Under review';
        break;
      case 'pending_guarantor':
      default:
        bg = AppTheme.amberLight;
        fg = AppTheme.amber;
        icon = Icons.warning_amber_outlined;
        label = 'Add guarantor ID';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: fg,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Stat widget ───────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Notification row ──────────────────────────────────────────────────────────
class _NotifRow extends StatelessWidget {
  final String text;
  final String time;
  final bool isUnread;
  const _NotifRow(
      {required this.text, required this.time, required this.isUnread});

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
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
                Text(text,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.grey800)),
                const SizedBox(height: 2),
                Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.grey400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}