import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'hk_edit_profile_screen.dart';
import 'hk_settings_screen.dart';

class HkProfileScreen extends StatelessWidget {
  const HkProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: Column(
        children: [
          _ProfileHeader(s: s),
          Container(
            color: AppTheme.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.visibility_outlined, size: 13, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text('This is how families see your profile',
                      style: const TextStyle(fontSize: 12, color: AppTheme.primaryText)),
                ]),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HkEditProfileScreen())),
                  icon: const Icon(Icons.edit_outlined, size: 13),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(s.aboutMe),
                  Text('Experienced and dependable housekeeper with 6 years working with families in Addis Ababa.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.6)),
                  const SizedBox(height: 16),
                  SectionLabel(s.skillsLabel),
                  Wrap(spacing: 6, runSpacing: 6, children: const [
                    SkillChip(label: 'Traditional Ethiopian cooking'),
                    SkillChip(label: 'Modern cooking'),
                    SkillChip(label: 'General cleaning'),
                    SkillChip(label: 'Laundry & ironing'),
                    SkillChip(label: 'Childcare'),
                  ]),
                  const SizedBox(height: 16),
                  SectionLabel(s.languagesLabel),
                  Wrap(spacing: 6, runSpacing: 6,
                    children: ['Amharic', 'Oromiffa', 'English'].map((l) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        border: Border.all(color: AppTheme.grey200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(l, style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.workingDaysLabel),
                  Row(
                    children: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map((d) {
                      final idx = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].indexOf(d);
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: idx < 6 ? 4 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(d, textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.jobDetails),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.grey200, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(children: [
                      InfoRow(label: s.workArrangementLabel, value: 'Live-out'),
                      const Divider(height: 0),
                      InfoRow(label: s.lookingForLabel, value: 'All household duties'),
                      const Divider(height: 0),
                      InfoRow(label: s.preferredAreaLabel, value: 'Bole, Kirkos'),
                      const Divider(height: 0),
                      InfoRow(label: s.expectedSalaryLabel, value: '4,000 – 5,000 Birr/mo'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.reviewsLabel),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Text('4.9',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('★★★★★', style: TextStyle(color: Color(0xFFEF9F27), fontSize: 16)),
                        const SizedBox(height: 3),
                        Text('${s.basedOn} 14 ${s.reviewsWord}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  _ReviewCard(name: 'The Kebede Family', stars: 5,
                      text: 'Tigist has been with us for 2 years. She cooks amazing injera and is wonderful with our children.'),
                  _ReviewCard(name: 'Ato Girma Wolde', stars: 5,
                      text: 'Very reliable, always on time, keeps the house spotless.'),
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

class _ProfileHeader extends StatelessWidget {
  final dynamic s;
  const _ProfileHeader({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    SizedBox(width: 5),
                    Text('Back', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ),
                Row(children: [
                  const LangToggleButton(),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.share_outlined, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(s.shareBtn, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HkSettingsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.settings_outlined, size: 18, color: Colors.white),
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 14),
            Row(children: [
              Stack(children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Text('TK', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
                ),
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.success, shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2)),
                  ),
                ),
              ]),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tigist Bekele',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const Text('Full-time housekeeper · Bole',
                    style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      const Icon(Icons.verified_user, size: 10, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(s.idVerified, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                    child: Text(s.profileLive, style: const TextStyle(color: Color(0xFF7FE9B5), fontSize: 10)),
                  ),
                ]),
              ]),
            ]),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                _Stat('4.9', s.rating),
                _Stat('24', s.views),
                _Stat('3', s.messages),
                _Stat('14', s.reviewsLabel),
              ]),
            ),
          ],
        ),
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
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          Text(l, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        ]),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int stars;
  final String text;
  const _ReviewCard({required this.name, required this.stars, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey200, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
          Text('★' * stars, style: const TextStyle(color: Color(0xFFEF9F27), fontSize: 11)),
        ]),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.grey600, height: 1.5)),
      ]),
    );
  }
}
