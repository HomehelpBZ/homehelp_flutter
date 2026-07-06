import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/language_provider.dart';
import '../../../widgets/shared_widgets.dart';
import 'step5_id_verify.dart';

class Step4JobPrefs extends StatefulWidget {
  const Step4JobPrefs({super.key});

  @override
  State<Step4JobPrefs> createState() => _Step4JobPrefsState();
}

class _Step4JobPrefsState extends State<Step4JobPrefs> {
  final Set<int> _jobTypeIndexes = {};
  String? _arrangement; // 'livein', 'liveout', 'either'
  final Map<int, bool> _days = {0:true,1:true,2:true,3:true,4:true,5:true,6:true};
  final Set<int> _areaIndexes = {};
  final _salaryController = TextEditingController();

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final jobTypes = s.jobTypeOptions;
    final arrangements = s.arrangementOptions;
    final dayLabels = s.dayLabels;
    final areaOptions = s.areaOptions;
    final showDays = _arrangement == 'liveout' || _arrangement == 'either';
    final showLiveInNote = _arrangement == 'livein';

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 14),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  StepProgressBar(currentStep: 4, totalSteps: 5),
                  const SizedBox(height: 10),
                  Text(s.stepJobPrefs,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(4, 5),
                      style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(s.lookingFor),
                  ...List.generate(jobTypes.length, (i) => _CheckRow(
                    label: jobTypes[i],
                    selected: _jobTypeIndexes.contains(i),
                    onTap: () => setState(() {
                      _jobTypeIndexes.contains(i)
                          ? _jobTypeIndexes.remove(i)
                          : _jobTypeIndexes.add(i);
                    }),
                  )),
                  const SizedBox(height: 16),
                  SectionLabel(s.workArrangement),
                  ...arrangements.map((arr) => _RadioRow(
                    label: arr.$2,
                    value: arr.$1,
                    groupValue: _arrangement,
                    onChanged: (v) => setState(() => _arrangement = v),
                  )),
                  if (showLiveInNote) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 15, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.liveInNote,
                              style: const TextStyle(fontSize: 11, color: AppTheme.primaryText, height: 1.5))),
                        ],
                      ),
                    ),
                  ],
                  if (showDays) ...[
                    const SizedBox(height: 16),
                    SectionLabel(s.workingDays),
                    Text(s.workingDaysNote,
                        style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 5,
                      children: List.generate(7, (i) => DayPill(
                        day: dayLabels[i],
                        isSelected: _days[i] ?? true,
                        onTap: () => setState(() => _days[i] = !(_days[i] ?? true)),
                      )),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SectionLabel(s.preferredArea),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: List.generate(areaOptions.length, (i) => FilterChip(
                      label: Text(areaOptions[i]),
                      selected: _areaIndexes.contains(i),
                      onSelected: (v) => setState(() => v ? _areaIndexes.add(i) : _areaIndexes.remove(i)),
                      selectedColor: AppTheme.primaryLight,
                      checkmarkColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: _areaIndexes.contains(i) ? AppTheme.primaryText : AppTheme.grey600),
                      side: BorderSide(
                        color: _areaIndexes.contains(i) ? AppTheme.primary : AppTheme.grey200, width: 0.5),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.expectedSalary),
                  TextFormField(
                    controller: _salaryController,
                    decoration: InputDecoration(hintText: s.salaryHint),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: s.continueBtn,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Step5IdVerify())),
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(label: s.backBtn, onPressed: () => Navigator.pop(context)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFEEEEEE), width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected, onChanged: (_) => onTap(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey800))),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  const _RadioRow({required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFEEEEEE), width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value, groupValue: groupValue, onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey800))),
          ],
        ),
      ),
    );
  }
}
