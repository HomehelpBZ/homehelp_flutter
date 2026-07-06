import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/job.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _activeChip = 'all';
  final Set<String> _expressedInterest = {};

  List<Job> get _filtered {
    return sampleJobs.where((job) {
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          job.jobType.toLowerCase().contains(q) ||
          job.area.toLowerCase().contains(q) ||
          job.familyLastName.toLowerCase().contains(q);
      final matchesChip = _activeChip == 'all' ||
          (_activeChip == 'cooking' && job.jobType.toLowerCase().contains('cook')) ||
          (_activeChip == 'cleaning' && job.jobType.toLowerCase().contains('clean')) ||
          (_activeChip == 'childcare' && job.jobType.toLowerCase().contains('child')) ||
          (_activeChip == 'livein' && job.arrangement.toLowerCase().contains('live-in')) ||
          (_activeChip == 'liveout' && job.arrangement.toLowerCase().contains('live-out'));
      return matchesQuery && matchesChip && job.status == 'open';
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
            child: results.isEmpty
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
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final job = results[i];
                      return _JobCard(
                        job: job,
                        s: s,
                        hasExpressedInterest: _expressedInterest.contains(job.id),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => JobDetailScreen(
                              job: job,
                              hasExpressedInterest: _expressedInterest.contains(job.id),
                              onExpressInterest: () => setState(() => _expressedInterest.add(job.id)),
                            ))),
                        onExpressInterest: () {
                          if (!_expressedInterest.contains(job.id)) {
                            setState(() => _expressedInterest.add(job.id));
                            showSuccessToast(context, s.interestExpressed);
                          }
                        },
                      );
                    },
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
