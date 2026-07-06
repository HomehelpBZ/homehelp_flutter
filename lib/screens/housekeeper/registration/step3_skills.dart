import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/language_provider.dart';
import '../../../widgets/shared_widgets.dart';
import 'step4_job_prefs.dart';

class Step3Skills extends StatefulWidget {
  const Step3Skills({super.key});

  @override
  State<Step3Skills> createState() => _Step3SkillsState();
}

class _Step3SkillsState extends State<Step3Skills> {
  final Set<int> _selectedSkillIndexes = {};
  final Set<int> _selectedLanguageIndexes = {};
  bool _showOtherLanguage = false;
  final _otherLangController = TextEditingController();

  @override
  void dispose() {
    _otherLangController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final skillOptions = s.skillOptions;
    final languageOptions = s.languageOptions;

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
                  StepProgressBar(currentStep: 3, totalSteps: 5),
                  const SizedBox(height: 10),
                  Text(s.stepSkills,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(3, 5),
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
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5))),
                    child: SectionLabel(s.skills),
                  ),
                  ...List.generate(skillOptions.length, (i) => _CheckTile(
                    label: skillOptions[i],
                    selected: _selectedSkillIndexes.contains(i),
                    onTap: () => setState(() {
                      _selectedSkillIndexes.contains(i)
                          ? _selectedSkillIndexes.remove(i)
                          : _selectedSkillIndexes.add(i);
                    }),
                  )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5))),
                    child: SectionLabel(s.language),
                  ),
                  ...List.generate(languageOptions.length, (i) => _CheckTile(
                    label: languageOptions[i],
                    selected: _selectedLanguageIndexes.contains(i),
                    onTap: () => setState(() {
                      _selectedLanguageIndexes.contains(i)
                          ? _selectedLanguageIndexes.remove(i)
                          : _selectedLanguageIndexes.add(i);
                    }),
                  )),
                  _CheckTile(
                    label: s.others,
                    selected: _showOtherLanguage,
                    onTap: () => setState(() => _showOtherLanguage = !_showOtherLanguage),
                  ),
                  if (_showOtherLanguage) ...[
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _otherLangController,
                      decoration: InputDecoration(hintText: s.otherLangHint),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: s.continueBtn,
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const Step4JobPrefs())),
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

class _CheckTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CheckTile({required this.label, required this.selected, required this.onTap});

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
