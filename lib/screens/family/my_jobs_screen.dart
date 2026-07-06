import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/job.dart';
import '../../models/housekeeper.dart';
import 'post_job_screen.dart';
import 'family_auth_screen.dart';
import 'family_chat_screen.dart';

class MyJobsScreen extends StatefulWidget {
  final bool isGuest;
  const MyJobsScreen({super.key, this.isGuest = false});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  // In a real app these would come from a backend
  // For prototype we show sample jobs as if the family posted them
  final List<Job> _myJobs = List.from(sampleJobs.take(2));

  void _deleteJob(Job job, s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.deleteJob,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(s.deleteJobConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: const TextStyle(color: AppTheme.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              setState(() => _myJobs.remove(job));
              Navigator.pop(context);
              showSuccessToast(context, s.jobDeletedSuccess);
            },
            child: Text(s.settingsDelete),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final isGuest = widget.isGuest;

    return Scaffold(
      appBar: navyAppBar(s.myJobs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => PostJobScreen(isGuest: isGuest)));
          if (result == true && !isGuest) {
            setState(() {});
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(s.postJob,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
      body: isGuest
          ? _GuestJobsPlaceholder(s: s)
          : _myJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_outline, size: 48, color: AppTheme.grey200),
                  const SizedBox(height: 14),
                  Text(s.noJobsPosted,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey600)),
                  const SizedBox(height: 6),
                  Text(s.noJobsPostedSub,
                      style: const TextStyle(fontSize: 12, color: AppTheme.grey400),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PostJobScreen(isGuest: isGuest))),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(s.postJob),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _myJobs.length,
              itemBuilder: (context, i) {
                final job = _myJobs[i];
                return _MyJobCard(
                  job: job,
                  s: s,
                  onEdit: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PostJobScreen(isEditing: true)));
                    if (result == true) setState(() {});
                  },
                  onDelete: () => _deleteJob(job, s),
                  onViewApplicants: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => InterestedHksScreen(job: job))),
                );
              },
            ),
    );
  }
}

// ── Guest placeholder ────────────────────────────────────────────────────────
class _GuestJobsPlaceholder extends StatelessWidget {
  final dynamic s;
  const _GuestJobsPlaceholder({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, size: 34, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(s.guestPostJobTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grey800),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(s.guestPostJobSubtitle,
                style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyAuthScreen()),
                  (route) => false,
                ),
                child: Text(s.createAccount),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyAuthScreen()),
                  (route) => false,
                ),
                child: Text(s.signInBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyJobCard extends StatelessWidget {
  final Job job;
  final dynamic s;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewApplicants;

  const _MyJobCard({
    required this.job, required this.s,
    required this.onEdit, required this.onDelete, required this.onViewApplicants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.grey200, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(job.jobType,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
                  Text('${job.area} · ${job.arrangement}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryText)),
                ]),
                _StatusBadge(status: job.status, s: s),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.payments_outlined, size: 14, color: AppTheme.grey400),
                  const SizedBox(width: 6),
                  Text('${job.salary.toStringAsFixed(0)} ${s.birr}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.grey400),
                  const SizedBox(width: 6),
                  Text(job.startDate,
                      style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                ]),
                const SizedBox(height: 8),
                if (job.description.isNotEmpty) ...[
                  Text(job.description,
                      style: const TextStyle(fontSize: 12, color: AppTheme.grey600, height: 1.5),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                ],
                // Interested count
                GestureDetector(
                  onTap: onViewApplicants,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: job.interestedCount > 0 ? AppTheme.amberLight : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.people_outline, size: 14,
                          color: job.interestedCount > 0 ? AppTheme.amber : AppTheme.grey400),
                      const SizedBox(width: 5),
                      Text('${job.interestedCount} ${s.interestedCount}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                              color: job.interestedCount > 0 ? AppTheme.amber : AppTheme.grey600)),
                      const SizedBox(width: 5),
                      Icon(Icons.chevron_right, size: 14,
                          color: job.interestedCount > 0 ? AppTheme.amber : AppTheme.grey400),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                // Actions
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 13),
                      label: Text(s.editJob),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: Size.zero,
                      ),
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 13, color: AppTheme.red),
                      label: Text(s.deleteJob,
                          style: const TextStyle(color: AppTheme.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: Size.zero,
                        side: const BorderSide(color: Color(0xFFF09595)),
                      ),
                      onPressed: onDelete,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final dynamic s;
  const _StatusBadge({required this.status, required this.s});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    if (status == 'open') {
      bg = const Color(0xFFDCFCE7); fg = const Color(0xFF166534);
      label = s.jobStatusOpen;
    } else if (status == 'filled') {
      bg = AppTheme.primaryLight; fg = AppTheme.primary;
      label = s.jobStatusFilled;
    } else {
      bg = AppTheme.grey200; fg = AppTheme.grey600;
      label = s.jobStatusClosed;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

// ── Interested HKs screen ─────────────────────────────────────────────────────
class InterestedHksScreen extends StatelessWidget {
  final Job job;
  const InterestedHksScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    // Sample interested HKs — in real app from backend
    final interested = sampleHousekeepers.take(job.interestedCount.clamp(0, 4)).toList();

    return Scaffold(
      appBar: navyAppBar(s.interestedHks),
      body: interested.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 48, color: AppTheme.grey200),
                  const SizedBox(height: 14),
                  Text(s.noInterestedHks,
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey400),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: interested.length,
              itemBuilder: (context, i) {
                final hk = interested[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.grey200, width: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        HkAvatar(initials: hk.initials, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(hk.name, style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                            Text('${hk.location} · ${hk.yearsExperience} ${s.yrs}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                            const SizedBox(height: 4),
                            Row(children: [
                              StarRating(rating: hk.rating, reviewCount: hk.reviewCount),
                              const SizedBox(width: 6),
                              const VerifiedBadge(),
                            ]),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.message_outlined, size: 13),
                            label: Text(s.startChat),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => FamilyChatScreen(hk: hk))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                              minimumSize: Size.zero,
                            ),
                            child: Text(s.ignore),
                          ),
                        ),
                      ]),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
