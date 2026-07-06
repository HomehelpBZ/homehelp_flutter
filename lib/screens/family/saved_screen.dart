import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import 'hk_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  final Set<String> savedIds;
  final List<Housekeeper> housekeepers;
  const SavedScreen({super.key, required this.savedIds, required this.housekeepers});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late Set<String> _saved;

  @override
  void initState() {
    super.initState();
    _saved = Set.from(widget.savedIds);
  }

  List<Housekeeper> get _savedHousekeepers =>
      widget.housekeepers.where((hk) => _saved.contains(hk.id)).toList();

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final list = _savedHousekeepers;
    return Scaffold(
      appBar: navyAppBar(s.savedHousekeepers),
      body: list.isEmpty
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
              itemCount: list.length,
              itemBuilder: (context, i) {
                final hk = list[i];
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
                            label: Text(s.messagesLabel),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 6),
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
                            onPressed: () => setState(() => _saved.remove(hk.id)),
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
