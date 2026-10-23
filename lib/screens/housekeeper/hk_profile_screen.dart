import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/reviews_section.dart';
import '../../widgets/hire_widgets.dart';
import 'hk_edit_profile_screen.dart';
import 'hk_settings_screen.dart';
import 'guarantor_id_screen.dart';

class HkProfileScreen extends StatefulWidget {
  const HkProfileScreen({super.key});

  @override
  State<HkProfileScreen> createState() => _HkProfileScreenState();
}

class _HkProfileScreenState extends State<HkProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _guarantor;
  String? _rejectionNote;
  bool _isLoading = true;
  bool _resubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await _userService.getHkProfile(uid);
      final guarantor = await _userService.getGuarantor(uid);
      final note = profile?['verificationStatus'] == 'rejected'
          ? await _userService.getRejectionNote(uid)
          : null;
      if (mounted) {
        setState(() {
          _profile = profile;
          _guarantor = guarantor;
          _rejectionNote = note;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resubmit() async {
    final s = LanguageProvider.strings(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ok = await showConfirmDialog(
      context,
      title: s.resubmitConfirmTitle,
      body: s.resubmitConfirmMsg,
      confirmLabel: s.resubmitBtn,
      cancelLabel: s.cancel,
    );
    if (!ok) return;
    setState(() => _resubmitting = true);
    try {
      await _userService.resubmitForReview(uid: uid);
      if (mounted) showSuccessToast(context, s.resubmitDone);
      _loadProfile();
    } catch (e) {
      debugPrint('Resubmit failed: $e');
      if (mounted) showErrorToast(context, s.errGeneric);
    } finally {
      if (mounted) setState(() => _resubmitting = false);
    }
  }

  void _editProfile() => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const HkEditProfileScreen()))
      .then((_) => _loadProfile());

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

    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final p = _profile ?? {};
    final name = p['fullName'] as String? ?? '';
    final region = p['region'] as String? ?? '';
    final arrangement = p['availability']?['arrangement'] as String? ?? '';
    final displayArrangement = arrangement == 'livein'
        ? s.filterLiveIn
        : arrangement == 'liveout'
            ? s.filterLiveOut
            : arrangement == 'either'
                ? (s.isAmharic ? 'ሁለቱም' : 'Either')
                : arrangement;
    final skills = (p['skills'] as List?)?.cast<String>() ?? [];
    final languages = (p['languages'] as List?)?.cast<String>() ?? [];
    final jobTypes = (p['jobTypes'] as List?)?.cast<String>() ?? [];
    final areas = ((p['preferredAreas'] as List?)?.cast<String>() ?? [])
        .map(s.areaName)
        .toList();
    final salary = p['rates']?['monthlyRate'] as String? ?? '';
    final bio = p['bio'] as String? ?? '';
    final verificationStatus =
        p['verificationStatus'] as String? ?? 'pending_guarantor';
    final availability = p['availability'] as Map<String, dynamic>? ?? {};
    final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayLabels = s.dayLabels;
    final isApproved = verificationStatus == 'approved';
    final isPendingGuarantor = verificationStatus == 'pending_guarantor';
    final isRejected = verificationStatus == 'rejected';

    return Scaffold(
      body: Column(
        children: [
          // Header
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
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(children: const [
                          Icon(Icons.arrow_back,
                              color: Colors.white70, size: 18),
                          SizedBox(width: 5),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      Row(children: [
                        const LangToggleButton(),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HkSettingsScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.settings_outlined,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor:
                          Colors.white.withOpacity(0.2),
                      child: Text(
                        _getInitials(name),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w500)),
                            Text(
                                '${displayArrangement.isNotEmpty ? displayArrangement : ''} · $region',
                                style: const TextStyle(
                                    color: Color(0xAAFFFFFF),
                                    fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(children: [
                              if (isApproved) ...[
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.18),
                                    borderRadius:
                                        BorderRadius.circular(
                                            20)),
                                  child: Row(children: [
                                    const Icon(
                                        Icons.verified_user,
                                        size: 10,
                                        color: Colors.white),
                                    const SizedBox(width: 3),
                                    Text(s.idVerified,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10)),
                                  ]),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success
                                        .withOpacity(0.25),
                                    borderRadius:
                                        BorderRadius.circular(
                                            20)),
                                  child: Text(s.profileLive,
                                      style: const TextStyle(
                                          color: Color(0xFF7FE9B5),
                                          fontSize: 10)),
                                ),
                              ] else
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isRejected
                                        ? AppTheme.redLight
                                        : AppTheme.amberLight,
                                    borderRadius:
                                        BorderRadius.circular(
                                            20)),
                                  child: Text(
                                    isRejected
                                        ? s.profileRejected
                                        : isPendingGuarantor
                                            ? 'Add guarantor ID'
                                            : s.settingsUnderReview,
                                    style: TextStyle(
                                        color: isRejected
                                            ? AppTheme.red
                                            : AppTheme.amber,
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.w500),
                                  ),
                                ),
                            ]),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      _Stat(UserService.ratingText(p),
                          s.rating),
                      _Stat('0', s.views),
                      _Stat('0', s.messages),
                      _Stat('${p[UserService.ratingCountField] ?? 0}',
                          s.reviewsLabel),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // Pending guarantor banner
          if (isPendingGuarantor)
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const GuarantorIdScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: AppTheme.amberLight,
                child: Row(children: [
                  const Icon(Icons.warning_amber_outlined,
                      size: 16, color: AppTheme.amber),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Add your guarantor\'s ID to complete verification',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF633806),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppTheme.amber),
                ]),
              ),
            ),

          // Rejected: show why, and let them fix and re-submit
          if (isRejected)
            _RejectedBanner(
              reason: p['rejectionReason'] as String?,
              note: _rejectionNote,
              resubmitting: _resubmitting,
              onEdit: _editProfile,
              onResubmit: _resubmit,
            ),

          // Edit banner
          Container(
            color: AppTheme.primaryLight,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 9),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.visibility_outlined,
                      size: 13, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                      'This is how families see your profile',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryText)),
                ]),
                ElevatedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined,
                      size: 13),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 6),
                    textStyle:
                        const TextStyle(fontSize: 12),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Bio
                  if (bio.isNotEmpty) ...[
                    SectionLabel(s.aboutMe),
                    Text(bio,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.grey600,
                            height: 1.6)),
                    const SizedBox(height: 16),
                  ],

                  // Skills
                  if (skills.isNotEmpty) ...[
                    SectionLabel(s.skillsLabel),
                    Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skills
                            .map((skill) =>
                                SkillChip(label: skill))
                            .toList()),
                    const SizedBox(height: 16),
                  ],

                  // Languages
                  if (languages.isNotEmpty) ...[
                    SectionLabel(s.languagesLabel),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: languages
                          .map((l) => Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFFF0F0F0),
                                  border: Border.all(
                                      color:
                                          AppTheme.grey200),
                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                                child: Text(l,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppTheme.grey600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Working days
                  SectionLabel(s.workingDaysLabel),
                  Row(
                    children: List.generate(7, (i) {
                      final key = dayKeys[i];
                      final isOn =
                          availability[key] == true;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              right: i < 6 ? 4 : 0),
                          padding: const EdgeInsets
                              .symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isOn
                                ? AppTheme.primary
                                : AppTheme.grey200,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Text(
                            dayLabels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isOn
                                    ? Colors.white
                                    : AppTheme.grey400,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w500),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Job details
                  SectionLabel(s.jobDetails),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.grey200,
                          width: 0.5),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Column(children: [
                      if (arrangement.isNotEmpty)
                        InfoRow(
                            label: s.workArrangementLabel,
                            value: displayArrangement),
                      if (jobTypes.isNotEmpty) ...[
                        const Divider(height: 0),
                        InfoRow(
                            label: s.lookingForLabel,
                            value: jobTypes.join(', ')),
                      ],
                      if (areas.isNotEmpty) ...[
                        const Divider(height: 0),
                        InfoRow(
                            label: s.preferredAreaLabel,
                            value: areas.join(', ')),
                      ],
                      if (salary.isNotEmpty) ...[
                        const Divider(height: 0),
                        InfoRow(
                            label: s.expectedSalaryLabel,
                            value: '$salary ${s.birr}'),
                      ],
                    ]),
                  ),
                  // Guarantor section
                  if (_guarantor != null) ...[
                    SectionLabel('Guarantor (ተያዥ)'),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppTheme.grey200, width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(children: [
                        InfoRow(label: 'Full name', value: _guarantor!['fullName'] ?? ''),
                        const Divider(height: 0),
                        InfoRow(label: 'Relationship', value: _guarantor!['relationship'] ?? ''),
                        const Divider(height: 0),
                        InfoRow(
                          label: 'ID type',
                          value: _guarantor!['idType'] ?? 'Not submitted',
                        ),
                        const Divider(height: 0),
                        InfoRow(
                          label: 'Verification',
                          value: _guarantor!['verificationStatus'] == 'verified'
                              ? s.guarantorVerified
                              : s.guarantorPendingCall,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ] else if (verificationStatus == 'pending_guarantor') ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.amberLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 18, color: AppTheme.amber),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Guarantor ID required',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF633806))),
                              SizedBox(height: 3),
                              Text("Add your guarantor's ID to complete verification",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF633806))),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const GuarantorIdScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Add now',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reviews from families, with a Reply button on each.
                  if (FirebaseAuth.instance.currentUser != null)
                    ReviewsSection(
                        hkUid: FirebaseAuth.instance.currentUser!.uid,
                        hkName: name,
                        canReply: true),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String v, l;
  const _Stat(this.v, this.l);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          Text(l,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10)),
        ]),
      ),
    );
  }
}
// ── Rejected banner ───────────────────────────────────────────────────────────
// Why the admin rejected the profile, with ways to fix it and send it back.
class _RejectedBanner extends StatelessWidget {
  final String? reason;
  final String? note;
  final bool resubmitting;
  final VoidCallback onEdit;
  final VoidCallback onResubmit;

  const _RejectedBanner({
    required this.reason,
    required this.note,
    required this.resubmitting,
    required this.onEdit,
    required this.onResubmit,
  });

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    const text = Color(0xFF791F1F);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.redLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.cancel, size: 16, color: AppTheme.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(s.rejectedTitle,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: text)),
            ),
          ]),
          if (reason != null && reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${s.rejectedReasonLabel}: ${s.rejectionReason(reason!)}',
                style: const TextStyle(fontSize: 12, color: text)),
          ],
          if (note != null && note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('${s.rejectedNoteLabel}: $note',
                style: const TextStyle(fontSize: 12, color: text)),
          ],
          const SizedBox(height: 8),
          Text(s.rejectedFixHint,
              style: const TextStyle(fontSize: 12, color: text, height: 1.4)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: resubmitting ? null : onEdit,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: Text(s.editProfile),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.red,
                  side: const BorderSide(color: AppTheme.red),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: resubmitting ? null : onResubmit,
                icon: const Icon(Icons.send_outlined, size: 14),
                label: Text(resubmitting ? s.loading : s.resubmitBtn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.red,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
