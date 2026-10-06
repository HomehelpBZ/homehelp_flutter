import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/job.dart';
import '../../services/user_service.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final _searchController = TextEditingController();
  final UserService _userService = UserService();
  String _query = '';
  String _activeChip = 'all';
  final Set<String> _expressedInterest = {};
  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String _hkStatus = '';

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _loadHkStatus();
  }

  void _loadHkStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('housekeeperProfiles')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() => _hkStatus = doc.data()?['verificationStatus'] ?? '');
      }
    }
  }

  void _loadJobs() async {
    try {
      final jobs = await _userService.getOpenJobs();
      // Check which jobs this HK already expressed interest in
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final alreadyInterested = <String>{};
      if (uid != null) {
        for (final job in jobs) {
          final hks = (job['interestedHks'] as List?)?.cast<String>() ?? [];
          if (hks.contains(uid)) {
            alreadyInterested.add(job['id'] as String);
          }
        }
      }
      if (mounted) setState(() {
        _jobs = jobs;
        _expressedInterest.addAll(alreadyInterested);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _jobs.where((job) {
      final q = _query.toLowerCase();
      final jobType = (job['jobType'] as String? ?? '').toLowerCase();
      final area = (job['area'] as String? ?? '').toLowerCase();
      final arrangement = (job['arrangement'] as String? ?? '').toLowerCase();

      final matchesQuery = q.isEmpty ||
          jobType.contains(q) ||
          area.contains(q);
      final matchesChip = _activeChip == 'all' ||
          (_activeChip == 'cooking' && jobType.contains('cook')) ||
          (_activeChip == 'cleaning' && jobType.contains('clean')) ||
          (_activeChip == 'childcare' && jobType.contains('child')) ||
          (_activeChip == 'livein' && arrangement.contains('livein')) ||
          (_activeChip == 'liveout' && arrangement.contains('liveout'));
      return matchesQuery && matchesChip;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final results = _filtered;

    return Scaffold(
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.topRight, child: const LangToggleButton()),
                  const SizedBox(height: 6),
                  Text(s.jobBoard,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: s.searchJobs,
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                              onPressed: () {
                                setState(() => _query = '');
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              _Chip(label: s.filterAll, value: 'all', active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _Chip(label: s.filterCooking, value: 'cooking', active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _Chip(label: s.filterCleaning, value: 'cleaning', active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _Chip(label: s.filterChildcare, value: 'childcare', active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _Chip(label: s.filterLiveIn, value: 'livein', active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _Chip(label: s.filterLiveOut, value: 'liveout', active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${results.length} ${s.jobsFound}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_off_outlined, size: 40, color: AppTheme.grey200),
                        const SizedBox(height: 12),
                        Text(s.noJobsFound,
                            style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadJobs(),
                    color: AppTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final job = results[i];
                        final jobId = job['id'] as String;
                        return _JobCardFirestore(
                          job: job,
                          s: s,
                          hasExpressedInterest: _expressedInterest.contains(jobId),
                          onTap: () {},
                          onExpressInterest: () async {
                            if (_hkStatus != 'approved') {
                              String title;
                              String message;
                              switch (_hkStatus) {
                                case 'pending_guarantor':
                                  title = 'Add guarantor ID first';
                                  message = 'Please add your guarantor ID to complete your profile before expressing interest in jobs.';
                                  break;
                                case 'pending_review':
                                  title = 'Profile under review';
                                  message = 'Your profile has been submitted and is being reviewed by our admin team. You will be notified once approved.';
                                  break;
                                case 'pending':
                                  title = 'Profile under review';
                                  message = 'Your profile is in our review queue. Please wait for admin approval before expressing interest.';
                                  break;
                                case 'rejected':
                                  title = 'Profile rejected';
                                  message = 'Your profile was not approved. Please contact support for more information.';
                                  break;
                                default:
                                  title = 'Profile not approved';
                                  message = 'Your profile needs to be approved by our admin team before you can express interest in jobs.';
                              }
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  content: Text(message),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              return;
                            }
                            if (!_expressedInterest.contains(jobId)) {
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                await _userService.expressInterest(
                                    jobId: jobId, hkUid: uid);
                              }
                              setState(() => _expressedInterest.add(jobId));
                              showSuccessToast(context, s.interestExpressed);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value, active;
  final ValueChanged<String> onTap;
  const _Chip({required this.label, required this.value, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = active == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isOn ? AppTheme.primary : Colors.white,
          border: Border.all(color: isOn ? AppTheme.primary : AppTheme.grey200, width: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11,
          fontWeight: isOn ? FontWeight.w500 : FontWeight.normal,
          color: isOn ? Colors.white : AppTheme.grey600)),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final dynamic s;
  final bool hasExpressedInterest;
  final VoidCallback onTap;
  final VoidCallback onExpressInterest;

  const _JobCard({
    required this.job, required this.s, required this.hasExpressedInterest,
    required this.onTap, required this.onExpressInterest,
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                ),
                Text('${job.salary.toStringAsFixed(0)} ${s.birr}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 4),
            Text('${job.familyLastName} ${s.familySuffix} · ${job.area} · ${job.arrangement}',
                style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.access_time, size: 12, color: AppTheme.grey400),
              const SizedBox(width: 4),
              Text('${s.postedLabel} ${job.postedAgo}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
              const SizedBox(width: 12),
              const Icon(Icons.people_outline, size: 12, color: AppTheme.grey400),
              const SizedBox(width: 4),
              Text('${job.interestedCount} ${s.interestedCount}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: hasExpressedInterest
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(s.alreadyExpressedInterest,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                color: AppTheme.primaryText)),
                      ]),
                    )
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.thumb_up_outlined, size: 14),
                      label: Text(s.expressInterest),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: onExpressInterest,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Job Detail Screen ─────────────────────────────────────────────────────────
class JobDetailScreen extends StatefulWidget {
  final Job job;
  final bool hasExpressedInterest;
  final VoidCallback onExpressInterest;

  const JobDetailScreen({
    super.key,
    required this.job,
    required this.hasExpressedInterest,
    required this.onExpressInterest,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late bool _expressed;

  @override
  void initState() {
    super.initState();
    _expressed = widget.hasExpressedInterest;
  }

  void _expressInterest(s) {
    setState(() => _expressed = true);
    widget.onExpressInterest();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 28, color: AppTheme.primary),
            ),
            const SizedBox(height: 14),
            Text(s.interestExpressed,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
            const SizedBox(height: 8),
            Text(s.interestExpressedSub,
                style: const TextStyle(fontSize: 12, color: AppTheme.grey600, height: 1.5),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.done),
            ),
          ),
        ],
      ),
    );
  }

  void _callFamily(s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.callBtn,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(s.callPrivacyMsg,
            style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: const TextStyle(color: AppTheme.grey600)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.call, size: 14),
            label: Text(s.callNow),
            onPressed: () async {
              Navigator.pop(context);
              // Open device dialer with placeholder number
              final uri = Uri(scheme: 'tel', path: '+251900000000');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.jobDetailTitle),
        actions: const [LangToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(job.jobType,
                            style: const TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s.jobStatusOpen,
                            style: const TextStyle(color: Colors.white, fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${job.familyLastName} ${s.familySuffix} · ${job.area}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      _HeaderStat('${job.salary.toStringAsFixed(0)}', s.birr),
                      _HeaderStat(job.arrangement, s.workArrangementLabel),
                      _HeaderStat('${job.interestedCount}', s.interestedCount),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details
            _DetailCard(children: [
              InfoRow(label: s.jobTitle.replaceAll(' *', ''), value: job.jobType),
              const Divider(height: 0),
              InfoRow(label: s.workArrangementLabel, value: job.arrangement),
              const Divider(height: 0),
              InfoRow(label: s.preferredAreaLabel, value: job.area),
              const Divider(height: 0),
              InfoRow(label: s.salaryLabel, value: '${job.salary.toStringAsFixed(0)} ${s.birr}'),
              const Divider(height: 0),
              InfoRow(label: s.jobStartDate, value: job.startDate),
              const Divider(height: 0),
              InfoRow(label: s.postedLabel, value: job.postedAgo),
            ]),
            const SizedBox(height: 14),

            // Working days
            SectionLabel(s.workingDaysLabel),
            Row(
              children: job.workingDays.asMap().entries.map((e) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: e.key < job.workingDays.length - 1 ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(e.value, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.w500)),
                ),
              )).toList(),
            ),

            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 14),
              SectionLabel(s.jobDescription),
              Text(job.description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.6)),
            ],

            const SizedBox(height: 20),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.amberLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, size: 15, color: AppTheme.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.callPrivacyMsg,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF633806), height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.phone_outlined, size: 14),
                  label: Text(s.callBtn),
                  onPressed: () => _callFamily(s),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _expressed
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(s.alreadyExpressedInterest,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryText)),
                        ]),
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.thumb_up_outlined, size: 14),
                        label: Text(s.expressInterest),
                        onPressed: () => _expressInterest(s),
                      ),
              ),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String v, l;
  const _HeaderStat(this.v, this.l);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.w500)),
          Text(l, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        ]),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.grey200, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _JobCardFirestore extends StatelessWidget {
  final Map<String, dynamic> job;
  final dynamic s;
  final bool hasExpressedInterest;
  final VoidCallback onTap;
  final VoidCallback onExpressInterest;

  const _JobCardFirestore({
    required this.job, required this.s, required this.hasExpressedInterest,
    required this.onTap, required this.onExpressInterest,
  });

  @override
  Widget build(BuildContext context) {
    final jobType = job['jobType'] as String? ?? '';
    final area = job['area'] as String? ?? '';
    final arrangement = job['arrangement'] as String? ?? '';
    final salary = job['salary'] as String? ?? '';
    final interestedCount = job['interestedCount'] as int? ?? 0;

    final displayArrangement = arrangement == 'livein' ? 'Live-in'
        : arrangement == 'liveout' ? 'Live-out'
        : arrangement == 'either' ? 'Either'
        : arrangement;

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(jobType, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey800))),
            Text('$salary ${s.birr}', style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 4),
          Text('$area · $displayArrangement',
              style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
          const SizedBox(height: 8),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: hasExpressedInterest
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(s.alreadyExpressedInterest, style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: AppTheme.primaryText)),
                    ]),
                  )
                : ElevatedButton.icon(
                    icon: const Icon(Icons.thumb_up_outlined, size: 14),
                    label: Text(s.expressInterest),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: onExpressInterest,
                  ),
          ),
        ]),
      ),
    );
  }
}