import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';

class HkEditProfileScreen extends StatefulWidget {
  const HkEditProfileScreen({super.key});

  @override
  State<HkEditProfileScreen> createState() => _HkEditProfileScreenState();
}

class _HkEditProfileScreenState extends State<HkEditProfileScreen> {
  final _nameController = TextEditingController(text: 'Tigist Bekele');
  final _phoneController = TextEditingController(text: '0912345678');
  final _bioController = TextEditingController(
      text: 'Experienced housekeeper with 6 years working with families in Addis Ababa.');
  final _salaryController = TextEditingController(text: '4,000 – 5,000 Birr');
  String? _arrangement = 'liveout';
  final Map<int, bool> _days = {0:true,1:true,2:true,3:true,4:true,5:true,6:true};
  final Set<int> _selectedSkillIndexes = {0, 3, 4, 7};

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    showSuccessToast(context, 'Profile updated successfully!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final skillOptions = s.skillOptions;
    final arrangements = s.arrangementOptions;
    final dayLabels = s.dayLabels;
    final showDays = _arrangement == 'liveout' || _arrangement == 'either';

    return Scaffold(
      appBar: AppBar(
        title: Text(s.editProfile),
        actions: const [LangToggleButton()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _save(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Profile photo',
              child: Row(children: [
                Stack(children: [
                  const CircleAvatar(
                    radius: 37, backgroundColor: AppTheme.primary,
                    child: Text('TK', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                    ),
                  ),
                ]),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Tigist Bekele',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                  const SizedBox(height: 3),
                  Text(s.tapPhotoToUpload,
                      style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: s.fullName,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionLabel(s.fullName),
                TextFormField(
                  controller: _nameController,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\u1200-\u137F]'))],
                ),
                const SizedBox(height: 12),
                SectionLabel(s.phoneNumber),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  decoration: const InputDecoration(counterText: ''),
                ),
                const SizedBox(height: 12),
                const SectionLabel('Bio'),
                TextFormField(controller: _bioController, maxLines: 3),
              ]),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: s.skillsLabel,
              child: Column(
                children: List.generate(skillOptions.length, (i) => GestureDetector(
                  onTap: () => setState(() {
                    _selectedSkillIndexes.contains(i)
                        ? _selectedSkillIndexes.remove(i)
                        : _selectedSkillIndexes.add(i);
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSkillIndexes.contains(i) ? AppTheme.primaryLight : Colors.white,
                      border: Border.all(
                        color: _selectedSkillIndexes.contains(i) ? AppTheme.primary : AppTheme.grey200,
                        width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Checkbox(
                        value: _selectedSkillIndexes.contains(i),
                        onChanged: (_) => setState(() {
                          _selectedSkillIndexes.contains(i)
                              ? _selectedSkillIndexes.remove(i)
                              : _selectedSkillIndexes.add(i);
                        }),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(skillOptions[i],
                          style: const TextStyle(fontSize: 13, color: AppTheme.grey800))),
                    ]),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: s.stepJobPrefs,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionLabel(s.workArrangement),
                ...arrangements.map((arr) => GestureDetector(
                  onTap: () => setState(() => _arrangement = arr.$1),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _arrangement == arr.$1 ? AppTheme.primaryLight : Colors.white,
                      border: Border.all(
                        color: _arrangement == arr.$1 ? AppTheme.primary : AppTheme.grey200, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Radio<String>(
                        value: arr.$1, groupValue: _arrangement,
                        onChanged: (v) => setState(() => _arrangement = v),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Text(arr.$2, style: const TextStyle(fontSize: 13, color: AppTheme.grey800)),
                    ]),
                  ),
                )),
                if (showDays) ...[
                  const SizedBox(height: 12),
                  SectionLabel(s.workingDays),
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
                const SizedBox(height: 12),
                SectionLabel(s.expectedSalary),
                TextFormField(controller: _salaryController),
              ]),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: s.saveChanges, onPressed: () => _save(context)),
            const SizedBox(height: 10),
            SecondaryButton(label: s.cancel, onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.grey200, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                color: AppTheme.grey600, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        const Divider(height: 0),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}
