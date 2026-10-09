import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/user_service.dart';
import 'hk_detail_screen.dart';
import '../../models/housekeeper.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _svc = UserService();
  List<Map<String, dynamic>> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    final hks = await _svc.getFavoriteHks(uid);
    if (mounted) setState(() { _saved = hks; _loading = false; });
  }

  Future<void> _remove(String hkId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _svc.removeFavorite(uid, hkId);
    setState(() => _saved.removeWhere((h) => h['id'] == hkId));
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      appBar: navyAppBar(s.savedHousekeepers),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _saved.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.heart_broken_outlined, size: 44, color: AppTheme.grey200),
                      const SizedBox(height: 14),
                      Text(s.noSaved, style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                      const SizedBox(height: 6),
                      Text(s.noSavedSub, style: const TextStyle(fontSize: 12, color: AppTheme.grey400)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _saved.length,
                  itemBuilder: (context, i) {
                    final data = _saved[i];
                    final hkId = data['id'] as String? ?? '';
                    final name = data['fullName'] as String? ?? '';
                    final region = data['region'] as String? ?? '';
                    final exp = data['yearsExperience']?.toString() ?? '0';
                    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
                    final reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
                    final initials = name.split(' ')
                        .where((w) => w.isNotEmpty).take(2)
                        .map((w) => w[0].toUpperCase()).join();
                    final hk = Housekeeper(
                      id: hkId,
                      name: name,
                      location: region,
                      yearsExperience: int.tryParse(exp) ?? 0,
                      rating: rating,
                      reviewCount: reviewCount,
                      skills: List<String>.from(data['skills'] ?? []),
                      arrangement: data['arrangement'] ?? '',
                      salary: data['salaryExpectation']?.toString() ?? '',
                      isVerified: data['isVerified'] == true,
                      profileImageUrl: data['profileImageUrl'],
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppTheme.grey200, width: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(children: [
                        Row(children: [
                          HkAvatar(initials: initials, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                              Text('$region · $exp ${s.yrs}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                              const SizedBox(height: 4),
                              Row(children: [
                                StarRating(rating: rating, reviewCount: reviewCount),
                                const SizedBox(width: 6),
                                if (hk.isVerified) const VerifiedBadge(),
                              ]),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.person_outline, size: 13),
                              label: Text(s.viewBtn),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => HkDetailScreen(hk: hk))),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.heart_broken_outlined, size: 13, color: AppTheme.red),
                              label: Text(s.removeBtn, style: const TextStyle(color: AppTheme.red)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                                minimumSize: Size.zero,
                                side: const BorderSide(color: Color(0xFFF09595)),
                              ),
                              onPressed: () => _remove(hkId),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
    );
  }
}
