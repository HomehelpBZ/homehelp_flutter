import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/user_service.dart';

class HkEditProfileScreen extends StatefulWidget {
  const HkEditProfileScreen({super.key});

  @override
  State<HkEditProfileScreen> createState() => _HkEditProfileScreenState();
}

class _HkEditProfileScreenState extends State<HkEditProfileScreen> {
  final UserService _userService = UserService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _salaryController = TextEditingController();
  String? _arrangement;
  final Map<int, bool> _days = {0:true,1:true,2:true,3:true,4:true,5:false,6:false};
  final Set<int> _selectedSkillIndexes = {};
  Uint8List? _photoBytes;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await _userService.getHkProfile(uid);
      if (profile != null && mounted) {
        final availability = profile['availability'] as Map<String, dynamic>? ?? {};
        final skills = (profile['skills'] as List?)?.cast<String>() ?? [];
        setState(() {
          _profile = profile;
          _nameController.text = profile['fullName'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _bioController.text = profile['bio'] ?? '';
          _salaryController.text = profile['rates']?['monthlyRate'] ?? '';
          _arrangement = availability['arrangement'] as String?;
          _days[0] = availability['mon'] ?? true;
          _days[1] = availability['tue'] ?? true;
          _days[2] = availability['wed'] ?? true;
          _days[3] = availability['thu'] ?? true;
          _days[4] = availability['fri'] ?? true;
          _days[5] = availability['sat'] ?? false;
          _days[6] = availability['sun'] ?? false;
          _isLoading = false;
        });

        // Pre-select skills based on saved skills
        // Will be matched by index after build
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _photoBytes = bytes);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _save(BuildContext context, List<String> skillOptions) async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final selectedSkills = _selectedSkillIndexes
            .map((i) => skillOptions[i])
            .toList();

        // Update step1 data
        await _userService.updateHkStep1(
          uid: uid,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          region: _profile?['region'] ?? '',
          ageRange: _profile?['ageRange'] ?? '',
          gender: _profile?['gender'] ?? '',
        );

        // Update skills
        await _userService.updateHkStep3(
          uid: uid,
          skills: selectedSkills,
          languages: (_profile?['languages'] as List?)?.cast<String>() ?? [],
        );

        // Update job prefs
        await _userService.updateHkStep4(
          uid: uid,
          jobTypes: (_profile?['jobTypes'] as List?)?.cast<String>() ?? [],
          arrangement: _arrangement ?? 'liveout',
          workingDays: {
            'mon': _days[0] ?? true,
            'tue': _days[1] ?? true,
            'wed': _days[2] ?? true,
            'thu': _days[3] ?? true,
            'fri': _days[4] ?? true,
            'sat': _days[5] ?? false,
            'sun': _days[6] ?? false,
          },
          preferredAreas: (_profile?['preferredAreas'] as List?)?.cast<String>() ?? [],
          expectedSalary: _salaryController.text.trim(),
        );

        // Update bio separately
        await _userService.updateHkBio(
          uid: uid,
          bio: _bioController.text.trim(),
        );
      }
      if (mounted) {
        showSuccessToast(context, 'Profile updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSuccessToast(context, 'Failed to save. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final skillOptions = s.skillOptions;
    final arrangements = s.arrangementOptions;
    final dayLabels = s.dayLabels;
    final showDays = _arrangement == 'liveout' || _arrangement == 'either';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    // Pre-select skills that match saved skills
    if (_profile != null && _selectedSkillIndexes.isEmpty) {
      final savedSkills =
          (_profile!['skills'] as List?)?.cast<String>() ?? [];
      for (int i = 0; i < skillOptions.length; i++) {
        if (savedSkills.contains(skillOptions[i])) {
          _selectedSkillIndexes.add(i);
        }
      }
    }

    final name = _nameController.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.editProfile),
        actions: const [LangToggleButton()],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            _SectionCard(
              title: 'Profile photo',
              child: Row(children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 37,
                      backgroundColor: AppTheme.primary,
                      backgroundImage: _photoBytes != null
                          ? MemoryImage(_photoBytes!)
                          : null,
                      child: _photoBytes == null
                          ? Text(
                              _getInitials(name),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 14),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.grey800)),
                      const SizedBox(height: 3),
                      Text(s.tapPhotoToUpload,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.grey600)),
                    ]),
              ]),
            ),
            const SizedBox(height: 14),

            // Personal info
            _SectionCard(
              title: s.fullName,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(s.fullName),
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s\u1200-\u137F]'))
                      ],
                    ),
                    const SizedBox(height: 12),
                    SectionLabel(s.phoneNumber),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      maxLength: 10,
                      decoration:
                          const InputDecoration(counterText: ''),
                    ),
                    const SizedBox(height: 12),
                    const SectionLabel('Bio'),
                    TextFormField(
                        controller: _bioController, maxLines: 3),
                  ]),
            ),
            const SizedBox(height: 14),

            // Skills
            _SectionCard(
              title: s.skillsLabel,
              child: Column(
                children: List.generate(
                    skillOptions.length,
                    (i) => GestureDetector(
                          onTap: () => setState(() {
                            _selectedSkillIndexes.contains(i)
                                ? _selectedSkillIndexes.remove(i)
                                : _selectedSkillIndexes.add(i);
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedSkillIndexes.contains(i)
                                  ? AppTheme.primaryLight
                                  : Colors.white,
                              border: Border.all(
                                color: _selectedSkillIndexes.contains(i)
                                    ? AppTheme.primary
                                    : AppTheme.grey200,
                                width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              Checkbox(
                                value:
                                    _selectedSkillIndexes.contains(i),
                                onChanged: (_) => setState(() {
                                  _selectedSkillIndexes.contains(i)
                                      ? _selectedSkillIndexes.remove(i)
                                      : _selectedSkillIndexes.add(i);
                                }),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(skillOptions[i],
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.grey800))),
                            ]),
                          ),
                        )),
              ),
            ),
            const SizedBox(height: 14),

            // Job preferences
            _SectionCard(
              title: s.stepJobPrefs,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(s.workArrangement),
                    ...arrangements.map((arr) => GestureDetector(
                          onTap: () =>
                              setState(() => _arrangement = arr.$1),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _arrangement == arr.$1
                                  ? AppTheme.primaryLight
                                  : Colors.white,
                              border: Border.all(
                                color: _arrangement == arr.$1
                                    ? AppTheme.primary
                                    : AppTheme.grey200,
                                width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              Radio<String>(
                                value: arr.$1,
                                groupValue: _arrangement,
                                onChanged: (v) =>
                                    setState(() => _arrangement = v),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Text(arr.$2,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.grey800)),
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
                        children: List.generate(
                            7,
                            (i) => DayPill(
                                  day: dayLabels[i],
                                  isSelected: _days[i] ?? true,
                                  onTap: () => setState(() =>
                                      _days[i] = !(_days[i] ?? true)),
                                )),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SectionLabel(s.expectedSalary),
                    TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number),
                  ]),
            ),
            const SizedBox(height: 20),

            PrimaryButton(
              label: s.saveChanges,
              isLoading: _isSaving,
              onPressed:
                  _isSaving ? null : () => _save(context, skillOptions),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
                label: s.cancel,
                onPressed: () => Navigator.pop(context)),
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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.grey600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            const Divider(height: 0),
            const SizedBox(height: 12),
            child,
          ]),
    );
  }
}