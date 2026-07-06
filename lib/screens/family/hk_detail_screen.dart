import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import 'family_chat_screen.dart';

class HkDetailScreen extends StatelessWidget {
  final Housekeeper hk;
  const HkDetailScreen({super.key, required this.hk});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: Column(
        children: [
          _DetailHeader(hk: hk, s: s),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hk.bio, style: const TextStyle(fontSize: 12, color: AppTheme.grey600, height: 1.6)),
                  const SizedBox(height: 16),
                  SectionLabel(s.skillsLabel),
                  Wrap(spacing: 6, runSpacing: 6,
                      children: hk.skills.map((sk) => SkillChip(label: sk)).toList()),
                  const SizedBox(height: 16),
                  SectionLabel(s.workingDaysLabel),
                  Row(
                    children: hk.availableDays.asMap().entries.map((e) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: e.key < hk.availableDays.length - 1 ? 4 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
                        child: Text(e.value, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.workArrangementLabel),
                  Text(
                    hk.arrangement == 'live-in'
                        ? 'Live-in. Available full-time.'
                        : 'Live-out (come daily). Prefers ${hk.location} and nearby areas.',
                    style: const TextStyle(fontSize: 12, color: AppTheme.grey600),
                  ),
                  const SizedBox(height: 10),
                  SectionLabel(s.languagesLabel),
                  Text(hk.languages.join(' · '),
                      style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                  const SizedBox(height: 16),
                  SectionLabel(s.reviewsLabel),
                  _ReviewCard(name: 'The Kebede Family', stars: 5,
                      text: 'Amazing cook and wonderful with children.'),
                  _ReviewCard(name: 'Ato Girma Wolde', stars: 5,
                      text: 'Very reliable, always on time, keeps the house spotless.'),
                  const SizedBox(height: 20),
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
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => FamilyChatScreen(hk: hk))),
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

class _DetailHeader extends StatelessWidget {
  final Housekeeper hk;
  final dynamic s;
  const _DetailHeader({required this.hk, required this.s});

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
                    SizedBox(width: 4),
                    Text('Back', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ),
                const LangToggleButton(),
              ],
            ),
            const SizedBox(height: 14),
            Row(children: [
              HkAvatar(initials: hk.initials, color: const Color(0x33FFFFFF), size: 64, fontSize: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(hk.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('${hk.location}, Addis Ababa',
                      style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.verified_user, size: 10, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(s.idVerified, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ]),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                _Stat('${hk.rating}', s.rating),
                _Stat('${hk.yearsExperience} ${s.yrs}', s.experience),
                _Stat('${hk.reviewCount}', s.reviewsLabel),
                _Stat('${hk.salaryMin.toStringAsFixed(0)}', s.perMonth),
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
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
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
