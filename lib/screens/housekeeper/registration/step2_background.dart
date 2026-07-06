import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/language_provider.dart';
import '../../../widgets/shared_widgets.dart';
import 'step3_skills.dart';

class Step2Background extends StatefulWidget {
  const Step2Background({super.key});

  @override
  State<Step2Background> createState() => _Step2BackgroundState();
}

class _Step2BackgroundState extends State<Step2Background> {
  String? _education;
  String? _experience;
  final _historyController = TextEditingController();

  @override
  void dispose() {
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
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
                  StepProgressBar(currentStep: 2, totalSteps: 5),
                  const SizedBox(height: 10),
                  Text(s.stepBackground,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(2, 5),
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
                  SectionLabel(s.educationLevel),
                  ...s.educationOptions.map((opt) => _RadioTile(
                        label: opt,
                        groupValue: _education,
                        value: opt,
                        onChanged: (v) => setState(() => _education = v),
                      )),
                  const SizedBox(height: 16),
                  SectionLabel(s.yearsExperience),
                  ...s.experienceOptions.map((opt) => _RadioTile(
                        label: opt,
                        groupValue: _experience,
                        value: opt,
                        onChanged: (v) => setState(() => _experience = v),
                      )),
                  const SizedBox(height: 16),
                  Row(children: [
                    SectionLabel(s.workHistory),
                    Text(s.optional, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                  ]),
                  TextFormField(
                    controller: _historyController,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: s.workHistoryHint),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: s.continueBtn,
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const Step3Skills())),
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

class _RadioTile extends StatelessWidget {
  final String label;
  final String? groupValue;
  final String value;
  final ValueChanged<String?> onChanged;

  const _RadioTile({required this.label, required this.groupValue,
      required this.value, required this.onChanged});

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
