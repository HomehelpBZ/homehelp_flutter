import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import 'family_chat_screen.dart';

class HkDetailScreen extends StatefulWidget {
  final String? uid;
  final Housekeeper? hk; // keep for backward compatibility
  const HkDetailScreen({super.key, this.uid, this.hk});

  @override
  State<HkDetailScreen> createState() => _HkDetailScreenState();
}

class _HkDetailScreenState extends State<HkDetailScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      _loadProfile();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('housekeeperProfiles')
          .doc(widget.uid)
          .get();
      if (mounted) {
        setState(() {
          _profile = doc.exists ? {'id': doc.id, ...doc.data()!} : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    // Use real Firestore data if available, otherwise fall back to sample hk
    final p = _profile;
    final name = p?['fullName'] as String? ?? widget.hk?.name ?? '';
    final region = p?['region'] as String? ?? '';
    final areas = (p?['preferredAreas'] as List?)?.cast<String>() ?? [];
    final location = areas.isNotEmpty ? areas.first : region;
    final skills = (p?['skills'] as List?)?.cast<String>() ?? widget.hk?.skills ?? [];
    final languages = (p?['languages'] as List?)?.cast<String>() ?? widget.hk?.languages ?? [];
    final bio = p?['bio'] as String? ?? widget.hk?.bio ?? '';
    final salary = p?['rates']?['monthlyRate'] as String? ?? '';
    final experience = p?['experienceYears'] as String? ?? widget.hk?.yearsExperience.toString() ?? '';
    final arrangement = p?['availability']?['arrangement'] as String? ?? '';
    final availability = p?['availability'] as Map<String, dynamic>? ?? {};
    final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayLabels = s.dayLabels;

    // Translate arrangement
    final isAmharic = s.isAmharic;
    final displayArrangement = arrangement == 'livein'
        ? (isAmharic ? 'አዳሪ' : 'Live-in')
        : arrangement == 'liveout'
            ? (isAmharic ? 'ተመላላሽ' : 'Live-out')
            : arrangement == 'either'
                ? (isAmharic ? 'ሁለቱም' : 'Either')
                : arrangement;

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
                          Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                          SizedBox(width: 4),
                          Text('Back', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      const LangToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.2),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            Text('$location · $displayArrangement',
                                style: const TextStyle(
                                    color: Color(0xAAFFFFFF), fontSize: 12)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.verified_user,
                                    size: 10, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(s.idVerified,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ]),
                            ),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      _Stat('0', s.rating),
                      _Stat(experience, s.experience),
                      _Stat('0', s.reviewsLabel),
                      _Stat('$salary ${s.birr}', s.perMonth),
                    ]),
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
                  // Bio
                  if (bio.isNotEmpty) ...[
                    Text(bio,
                        style: const TextStyle(
                            fontSize: 12,
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
                            .map((sk) => SkillChip(label: sk))
                            .toList()),
                    const SizedBox(height: 16),
                  ],

                  // Languages
                  if (languages.isNotEmpty) ...[
                    SectionLabel(s.languagesLabel),
                    Text(languages.join(' · '),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.grey600)),
                    const SizedBox(height: 16),
                  ],

                  // Working days
                  if (availability.isNotEmpty) ...[
                    SectionLabel(s.workingDaysLabel),
                    Row(
                      children: List.generate(7, (i) {
                        final key = dayKeys[i];
                        final isOn = availability[key] == true;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 6 ? 4 : 0),
                            padding:
                                const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? AppTheme.primary
                                  : AppTheme.grey200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              dayLabels[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isOn
                                      ? Colors.white
                                      : AppTheme.grey400,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Job details
                  SectionLabel(s.jobDetails),
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppTheme.grey200, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(children: [
                      if (displayArrangement.isNotEmpty)
                        InfoRow(
                            label: s.workArrangementLabel,
                            value: displayArrangement),
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
                            value: '$salary ${s.birr}/mo'),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone_outlined, size: 14),
                        label: Text(s.callBtn),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.message_outlined, size: 14),
                        label: Text(s.sendMessage),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FamilyChatScreen(
                                    hk: widget.hk ??
                                        sampleHousekeepers.first))),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Text(l,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 10)),
        ]),
      ),
    );
  }
}