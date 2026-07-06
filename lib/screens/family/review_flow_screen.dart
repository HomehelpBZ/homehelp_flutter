import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import '../family/browse_screen.dart';

class ReviewFlowScreen extends StatefulWidget {
  final Housekeeper hk;
  const ReviewFlowScreen({super.key, required this.hk});

  @override
  State<ReviewFlowScreen> createState() => _ReviewFlowScreenState();
}

class _ReviewFlowScreenState extends State<ReviewFlowScreen> {
  int _step = 0;
  int _starRating = 0;
  bool? _wouldHireAgain;
  final Set<int> _selectedTagIndexes = {};
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _stepTitle(s) {
    return [s.hireConfirmation, s.starRatingTitle, s.hireAgainTitle, s.writeReviewTitle, s.reviewsLabel][_step];
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(s)),
        actions: const [LangToggleButton()],
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--))
            : null,
        automaticallyImplyLeading: _step > 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: [
          () => _buildHireConfirm(s),
          () => _buildStarRating(s),
          () => _buildHireAgain(s),
          () => _buildWriteReview(s),
          () => _buildDone(s),
        ][_step](),
      ),
    );
  }

  Widget _buildHireConfirm(s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HkMiniCard(hk: widget.hk, subtitle: null),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            border: Border.all(color: const Color(0xFF93C5FD)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.hireDetails, style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500, color: AppTheme.primaryText, letterSpacing: 0.4)),
            const SizedBox(height: 5),
            const Text('All household duties · Live-out',
                style: TextStyle(fontSize: 13, color: AppTheme.primaryText)),
            const Text('4,500 Birr per month',
                style: TextStyle(fontSize: 13, color: AppTheme.primaryText)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(s.startDate, style: const TextStyle(fontSize: 12, color: AppTheme.primaryText)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        Text(s.hireConfirmNote,
            style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.6)),
        const SizedBox(height: 20),
        PrimaryButton(label: s.confirmHire, onPressed: () => setState(() => _step = 1)),
        const SizedBox(height: 10),
        SecondaryButton(label: s.cancel, onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildStarRating(s) {
    final labels = s.starLabels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HkMiniCard(hk: widget.hk, subtitle: null),
        const SizedBox(height: 20),
        SectionLabel(s.howWouldYouRate),
        const SizedBox(height: 6),
        Center(child: Text(
          _starRating > 0 ? labels[_starRating] : s.tapStarToRate,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey600),
        )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _starRating = i + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                i < _starRating ? Icons.star : Icons.star_border,
                size: 38,
                color: i < _starRating ? const Color(0xFFEF9F27) : AppTheme.grey200,
              ),
            ),
          )),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: s.continueBtn,
          onPressed: _starRating > 0 ? () => setState(() => _step = 2) : null,
        ),
        const SizedBox(height: 10),
        SecondaryButton(label: s.backBtn, onPressed: () => setState(() => _step = 0)),
      ],
    );
  }

  Widget _buildHireAgain(s) {
    final tags = s.tagOptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HkMiniCard(hk: widget.hk, subtitle: null),
        const SizedBox(height: 20),
        SectionLabel(s.wouldYouHireAgain),
        Row(children: [
          Expanded(child: _HireAgainBtn(
            icon: Icons.thumb_up_outlined,
            label: s.yesDefinitely,
            selected: _wouldHireAgain == true,
            isYes: true,
            onTap: () => setState(() => _wouldHireAgain = _wouldHireAgain == true ? null : true),
          )),
          const SizedBox(width: 10),
          Expanded(child: _HireAgainBtn(
            icon: Icons.thumb_down_outlined,
            label: s.noProbably,
            selected: _wouldHireAgain == false,
            isYes: false,
            onTap: () => setState(() => _wouldHireAgain = _wouldHireAgain == false ? null : false),
          )),
        ]),
        const SizedBox(height: 6),
        Center(child: Text(s.tapToDeselect,
            style: const TextStyle(fontSize: 11, color: AppTheme.grey400))),
        const SizedBox(height: 16),
        SectionLabel(s.whatDidTheyDoWell),
        Text(s.tapToSelect, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: List.generate(tags.length, (i) {
            final selected = _selectedTagIndexes.contains(i);
            return GestureDetector(
              onTap: () => setState(() {
                selected ? _selectedTagIndexes.remove(i) : _selectedTagIndexes.add(i);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryLight : Colors.white,
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.grey200,
                    width: selected ? 1.5 : 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tags[i], style: TextStyle(
                  fontSize: 12,
                  color: selected ? AppTheme.primaryText : AppTheme.grey600,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.normal)),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: s.continueBtn,
          onPressed: _wouldHireAgain != null ? () => setState(() => _step = 3) : null,
        ),
        const SizedBox(height: 10),
        SecondaryButton(label: s.backBtn, onPressed: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _buildWriteReview(s) {
    final charCount = _reviewController.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HkMiniCard(
          hk: widget.hk,
          subtitle: _starRating > 0
              ? '${'★' * _starRating}${'☆' * (5 - _starRating)}'
              : null,
        ),
        const SizedBox(height: 20),
        Row(children: [
          SectionLabel(s.yourReview),
          Text(s.optional, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
        ]),
        TextFormField(
          controller: _reviewController,
          maxLines: 5,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: s.reviewHint),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text('$charCount / 300',
              style: TextStyle(fontSize: 11,
                  color: charCount > 300 ? AppTheme.red : AppTheme.grey400)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, size: 15, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(s.reviewPublicNote,
                style: const TextStyle(fontSize: 11, color: AppTheme.primaryText, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: s.submitReview,
          onPressed: charCount <= 300 ? () => setState(() => _step = 4) : null,
        ),
        const SizedBox(height: 10),
        SecondaryButton(label: s.skipAndSubmit, onPressed: () => setState(() => _step = 4)),
        const SizedBox(height: 10),
        SecondaryButton(label: s.backBtn, onPressed: () => setState(() => _step = 2)),
      ],
    );
  }

  Widget _buildDone(s) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.star, size: 34, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text('★' * _starRating + '☆' * (5 - _starRating),
              style: const TextStyle(color: Color(0xFFEF9F27), fontSize: 22)),
          const SizedBox(height: 12),
          Text(s.reviewSubmitted,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(s.reviewSubmittedNote,
                style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.6),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: s.backToBrowse,
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const BrowseScreen()),
              (r) => false,
            ),
          ),
        ],
      ),
    );
  }
}

class _HkMiniCard extends StatelessWidget {
  final Housekeeper hk;
  final String? subtitle;
  const _HkMiniCard({required this.hk, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        HkAvatar(initials: hk.initials, color: AppTheme.primary, size: 44),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hk.name, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
          Text(subtitle ?? s.reviewedHousekeeper,
              style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
        ]),
      ]),
    );
  }
}

class _HireAgainBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isYes;
  final VoidCallback onTap;
  const _HireAgainBtn({required this.icon, required this.label,
      required this.selected, required this.isYes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selectedColor = isYes ? AppTheme.primary : AppTheme.red;
    final selectedBg = isYes ? AppTheme.primaryLight : AppTheme.redLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.white,
          border: Border.all(
            color: selected ? selectedColor : AppTheme.grey200,
            width: selected ? 1.5 : 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, size: 22, color: selected ? selectedColor : AppTheme.grey600),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: selected ? selectedColor : AppTheme.grey600)),
        ]),
      ),
    );
  }
}
