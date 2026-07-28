import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../l10n/language_provider.dart';
import '../../../services/admin_service.dart';
import '../welcome_screen.dart';
import 'admin_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, int> _stats = {
    'pending': 0,
    'approvedToday': 0,
    'rejectedToday': 0,
    'totalActive': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      final stats = await _adminService.getStats();
      if (mounted) setState(() => _stats = stats);
    } catch (e) {
      // Stats load silently
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Admin Dashboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: _signOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: const [
                            Icon(Icons.logout,
                                size: 14, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Sign out',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Stats row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      _StatBox('${_stats['pending']}', 'Pending',
                          const Color(0xFFFFD166)),
                      _StatBox('${_stats['approvedToday']}',
                          'Approved today', const Color(0xFF06D6A0)),
                      _StatBox('${_stats['rejectedToday']}',
                          'Rejected today', const Color(0xFFEF476F)),
                      _StatBox('${_stats['totalActive']}', 'Total active',
                          Colors.white),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // Queue list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getPendingQueue(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading queue',
                        style: const TextStyle(color: AppTheme.grey600)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 52, color: AppTheme.primary),
                        const SizedBox(height: 14),
                        const Text('All caught up!',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.grey800)),
                        const SizedBox(height: 6),
                        const Text('No pending profiles to review.',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.grey600)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadStats,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadStats(),
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data =
                          docs[i].data() as Map<String, dynamic>;
                      final uid = data['housekeeperId'] as String? ?? '';
                      final submittedAt =
                          data['submittedAt'] as Timestamp?;
                      final timeAgo = submittedAt != null
                          ? _timeAgo(submittedAt.toDate())
                          : 'Unknown';

                      return _QueueCard(
                        uid: uid,
                        timeAgo: timeAgo,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminReviewScreen(
                              housekeeperId: uid,
                              onActionComplete: _loadStats,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBox(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 9),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final String uid;
  final String timeAgo;
  final VoidCallback onTap;
  const _QueueCard(
      {required this.uid, required this.timeAgo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('housekeeperProfiles')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final name = data?['fullName'] as String? ?? 'Unknown';
        final phone = data?['phone'] as String? ?? '';
        final region = data?['region'] as String? ?? '';
        final faydaId = data?['faydaId'] as String? ?? 'Not provided';

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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.grey800)),
                      const SizedBox(height: 2),
                      Text('+251$phone · $region',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.grey600)),
                      const SizedBox(height: 2),
                      Text('Fayda: $faydaId',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.grey400)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.amberLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Pending',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.amber)),
                    ),
                    const SizedBox(height: 4),
                    Text(timeAgo,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.grey400)),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppTheme.grey400),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
