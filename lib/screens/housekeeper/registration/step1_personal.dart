import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../l10n/language_provider.dart';
import 'step2_background.dart';

class Step1Personal extends StatefulWidget {
  final String? fullName;
  final String? phone;

  const Step1Personal({super.key, this.fullName, this.phone});

  @override
  State<Step1Personal> createState() => _Step1PersonalState();
}

class _Step1PersonalState extends State<Step1Personal> {
  XFile? _photo;
  Uint8List? _photoBytes;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedRegion;
  String? _selectedAge;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Pre-fill from signup if provided
    _nameController = TextEditingController(text: widget.fullName ?? '');
    _phoneController = TextEditingController(text: widget.phone ?? '');
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _photo = image;
        _photoBytes = bytes;
      });
    }
  }

  bool get _isValid =>
      _photo != null &&
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.length == 9 &&
      _selectedRegion != null &&
      _selectedAge != null &&
      _selectedGender != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                          Icon(Icons.arrow_back,
                              color: Colors.white70, size: 18),
                          SizedBox(width: 4),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      const LangToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StepProgressBar(currentStep: 1, totalSteps: 6),
                  const SizedBox(height: 10),
                  Text(s.stepPersonal,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(1, 6),
                      style: const TextStyle(
                          color: Color(0xAAFFFFFF), fontSize: 12)),
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
                  // Profile photo
                  SectionLabel(s.profilePhoto),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: CircleAvatar(
                          radius: 37,
                          backgroundColor: AppTheme.primary,
                          backgroundImage: _photoBytes != null
                              ? MemoryImage(_photoBytes!)
                              : null,
                          child: _photoBytes == null
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt,
                                        color: Colors.white, size: 20),
                                    Text('Upload',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.uploadClearPhoto,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.grey800)),
                          const SizedBox(height: 3),
                          Text(s.faceVisible,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.grey600)),
                          if (_photo != null) ...[
                            const SizedBox(height: 5),
                            Row(children: [
                              const Icon(Icons.check_circle,
                                  size: 13, color: AppTheme.primary),
                              const SizedBox(width: 4),
                              Text(s.photoUploaded,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.primary)),
                            ]),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Full name — pre-filled
                  SectionLabel(s.fullName),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s\u1200-\u137F]'))
                    ],
                    decoration:
                        InputDecoration(hintText: s.fullNameHint),
                  ),
                  const SizedBox(height: 14),

                  // Phone number — pre-filled with +251 prefix
                  SectionLabel(s.phoneNumber),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '912 345 678',
                      counterText: '',
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: const Text('+251',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey800,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(s.phoneNote,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.grey400)),
                  const SizedBox(height: 14),

                  // Place of birth
                  SectionLabel(s.placeOfBirth),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    hint: Text(s.selectRegion,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.grey400)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: s.regions
                        .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style:
                                    const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedRegion = v),
                  ),
                  const SizedBox(height: 14),

                  // Age
                  SectionLabel(s.age),
                  DropdownButtonFormField<String>(
                    value: _selectedAge,
                    hint: Text(s.selectAgeRange,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.grey400)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: s.ageRanges
                        .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a,
                                style:
                                    const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedAge = v),
                  ),
                  const SizedBox(height: 14),

                  // Gender
                  SectionLabel(s.gender),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    hint: Text(s.selectGender,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.grey400)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: [s.female, s.male]
                        .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g,
                                style:
                                    const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedGender = v),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: s.continueBtn,
                    onPressed: _isValid
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const Step2Background()))
                        : null,
                  ),
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