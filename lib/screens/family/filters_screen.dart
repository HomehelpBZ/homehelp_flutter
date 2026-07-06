import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final Set<int> _jobTypeIndexes = {};
  final Set<String> _arrangements = {};
  String? _area;
  String? _experience;
  String? _budget;
  final Set<String> _languages = {};

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final jobTypes = s.jobTypeOptions;
    final budgetOptions = s.budgetOptions;
    final experienceOptions = s.experienceOptions;

    return Scaffold(
      appBar: navyAppBar(s.filterHousekeepers),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(s.jobType),
            ...List.generate(jobTypes.length, (i) => _CheckRow(
              label: jobTypes[i],
              selected: _jobTypeIndexes.contains(i),
              onTap: () => setState(() {
                _jobTypeIndexes.contains(i)
                    ? _jobTypeIndexes.remove(i)
                    : _jobTypeIndexes.add(i);
              }),
            )),
            const SizedBox(height: 14),
            SectionLabel(s.workArrangement),
            ...['live-in', 'live-out'].map((a) => _CheckRow(
              label: a == 'live-in'
                  ? s.arrangementOptions[0].$2
                  : s.arrangementOptions[1].$2,
              selected: _arrangements.contains(a),
              onTap: () => setState(() {
                _arrangements.contains(a) ? _arrangements.remove(a) : _arrangements.add(a);
              }),
            )),
            const SizedBox(height: 14),
            SectionLabel(s.preferredArea),
            DropdownButtonFormField<String>(
              value: _area,
              hint: Text(s.anyArea, style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: ['Bole','Kirkos','Yeka','Lideta','Arada','Nifas Silk-Lafto','Akaky Kaliti']
                  .map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) => setState(() => _area = v),
            ),
            const SizedBox(height: 14),
            SectionLabel(s.yearsExperience),
            DropdownButtonFormField<String>(
              value: _experience,
              hint: Text(s.anyExperience, style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: experienceOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: 14),
            SectionLabel(s.budget),
            DropdownButtonFormField<String>(
              value: _budget,
              hint: Text(s.anyBudget, style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: budgetOptions
                  .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) => setState(() => _budget = v),
            ),
            const SizedBox(height: 14),
            SectionLabel(s.languagesLabel),
            ...['Amharic','Oromiffa','Tigrigna','English'].map((l) => _CheckRow(
              label: l,
              selected: _languages.contains(l),
              onTap: () => setState(() {
                _languages.contains(l) ? _languages.remove(l) : _languages.add(l);
              }),
            )),
            const SizedBox(height: 24),
            PrimaryButton(label: s.applyFilters, onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 10),
            SecondaryButton(
              label: s.resetAll,
              onPressed: () => setState(() {
                _jobTypeIndexes.clear(); _arrangements.clear();
                _area = null; _experience = null; _budget = null; _languages.clear();
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CheckRow({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.white,
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.grey200, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Checkbox(
            value: selected, onChanged: (_) => onTap(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey800))),
        ]),
      ),
    );
  }
}
