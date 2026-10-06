import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../family/hk_detail_screen.dart';

class InterestedHksScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const InterestedHksScreen({super.key, required this.job});

  @override
  State<InterestedHksScreen> createState() => _InterestedHksScreenState();
}

class _InterestedHksScreenState extends State<InterestedHksScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _hkProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterestedHks();
  }

  void _loadInterestedHks() async {
    try {
      final interestedHks = (widget.job['interestedHks'] as List?)
              ?.cast<String>() ??
          [];

      if (interestedHks.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final profiles = <Map<String, dynamic>>[];
      for (final uid in interestedHks) {
        final doc = await _db
            .collection('housekeeperProfiles')
            .doc(uid)
            .get();
        if (doc.exists) {
          profiles.add({'id': uid, ...doc.data()!});
        }
      }

      if (mounted) {
        setState(() {
          _hkProfiles = profiles;
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
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final jobType = widget.job['jobType'] as String? ?? '';
    final area = widget.job['area'] as String? ?? '';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(children: const [
                      Icon(Icons.arrow_back,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 4),
                      Text('Back',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Text(s.interestedHks,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('$jobType · $area',
                      style: const TextStyle(
                          color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : _hkProfiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline,
                                size: 52, color: AppTheme.grey200),
                            const SizedBox(height: 14),
                            Text(s.noInterestedHks,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grey400),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _hkProfiles.length,
                        itemBuilder: (context, i) {
                          final hk = _hkProfiles[i];
                          final uid = hk['id'] as String;
                          final name = hk['fullName'] as String? ?? '';
                          final region = hk['region'] as String? ?? '';
                          final experience =
                              hk['experienceYears'] as String? ?? '';
                          final skills = (hk['skills'] as List?)
                                  ?.cast<String>() ??
                              [];
                          final areas = (hk['preferredAreas'] as List?)
                                  ?.cast<String>() ??
                              [];
                          final location =
                              areas.isNotEmpty ? areas.first : region;

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HkDetailScreen(uid: uid),
                              ),
                            ),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: AppTheme.grey200,
                                    width: 0.5),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Column(children: [
                                Row(children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppTheme.primary,
                                    child: Text(
                                      _getInitials(name),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w500,
                                                color:
                                                    AppTheme.grey800)),
                                        const SizedBox(height: 2),
                                        Text(
                                            '$location · $experience',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppTheme.grey600)),
                                        const SizedBox(height: 4),
                                        const VerifiedBadge(),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: AppTheme.grey400),
                                ]),
                                if (skills.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: skills
                                        .take(3)
                                        .map((skill) => Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                    0xFFF0F0F0),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(20),
                                              ),
                                              child: Text(skill,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme
                                                          .grey600)),
                                            ))
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                          Icons.person_outline,
                                          size: 14),
                                      label: Text(s.viewBtn),
                                      style: ElevatedButton.styleFrom(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8),
                                        textStyle: const TextStyle(
                                            fontSize: 12),
                                        minimumSize: Size.zero,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              HkDetailScreen(uid: uid),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                          Icons.message_outlined,
                                          size: 14),
                                      label: Text(s.sendMessage),
                                      style: OutlinedButton.styleFrom(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8),
                                        textStyle: const TextStyle(
                                            fontSize: 12),
                                        minimumSize: Size.zero,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ]),
                              ]),
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