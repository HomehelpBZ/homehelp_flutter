import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/user_service.dart';
import 'hk_dashboard_screen.dart';

class GuarantorIdScreen extends StatefulWidget {
  const GuarantorIdScreen({super.key});

  @override
  State<GuarantorIdScreen> createState() => _GuarantorIdScreenState();
}

class _GuarantorIdScreenState extends State<GuarantorIdScreen> {
  final UserService _userService = UserService();
  final _faydaController = TextEditingController();
  String? _selectedIdType;
  Uint8List? _idPhotoBytes;
  bool _isSaving = false;

  bool get _isValid => _selectedIdType != null;

  @override
  void dispose() {
    _faydaController.dispose();
    super.dispose();
  }

  Future<void> _pickIdPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _idPhotoBytes = bytes);
    }
  }

  void _submit() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _userService.saveGuarantorId(
          uid: uid,
          idType: _selectedIdType!,
          faydaId: _faydaController.text.trim().isEmpty
              ? null
              : _faydaController.text.trim(),
        );
      }
      if (mounted) {
        showSuccessToast(context,
            'Guarantor ID submitted! Your profile is now under review.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HkDashboardScreen()),
          (r) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showSuccessToast(context, 'Failed to submit. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final idTypes = [
      s.guarantorIdTypeFayda,
      s.guarantorIdTypeKebele,
      s.guarantorIdTypePassport,
      s.guarantorIdTypeDriving,
      s.guarantorIdTypeOther,
    ];

    return Scaffold(
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
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
                  const SizedBox(height: 12),
                  Text(s.guarantorIdTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(s.guarantorIdSubtitle,
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
                  const SizedBox(height: 4),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.amberLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 15, color: AppTheme.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.guarantorIdNote,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF633806),
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ID type selection
                  SectionLabel(s.guarantorIdTypeLabel),
                  ...idTypes.map((type) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIdType = type),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedIdType == type
                                ? AppTheme.primaryLight
                                : Colors.white,
                            border: Border.all(
                              color: _selectedIdType == type
                                  ? AppTheme.primary
                                  : AppTheme.grey200,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Radio<String>(
                              value: type,
                              groupValue: _selectedIdType,
                              onChanged: (v) =>
                                  setState(() => _selectedIdType = v),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Text(type,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grey800)),
                          ]),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Fayda ID number (optional)
                  Row(children: [
                    SectionLabel(s.guarantorFaydaIdLabel),
                    Text(s.optional,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.grey400)),
                  ]),
                  TextFormField(
                    controller: _faydaController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: s.guarantorFaydaIdHint,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ID photo upload
                  SectionLabel(s.guarantorIdPhotoLabel),
                  GestureDetector(
                    onTap: _pickIdPhoto,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _idPhotoBytes != null
                            ? AppTheme.primaryLight
                            : Colors.white,
                        border: Border.all(
                          color: _idPhotoBytes != null
                              ? AppTheme.primary
                              : AppTheme.grey200,
                          width: _idPhotoBytes != null ? 1.5 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _idPhotoBytes != null
                          ? Column(children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(11)),
                                child: Image.memory(
                                  _idPhotoBytes!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.refresh,
                                          size: 14,
                                          color: AppTheme.primary),
                                      const SizedBox(width: 5),
                                      Text(s.changePhoto,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.primary)),
                                    ]),
                              ),
                            ])
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Column(children: [
                                const Icon(Icons.cloud_upload_outlined,
                                    size: 36, color: AppTheme.grey400),
                                const SizedBox(height: 8),
                                Text(s.guarantorIdPhotoUpload,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.grey800)),
                                const SizedBox(height: 4),
                                Text(s.guarantorIdPhotoSub,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.grey400),
                                    textAlign: TextAlign.center),
                              ]),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(s.guarantorIdPhotoNote,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.grey400)),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: s.guarantorIdSubmitBtn,
                    isLoading: _isSaving,
                    onPressed: _isValid ? _submit : null,
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: s.guarantorIdLaterBtn,
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HkDashboardScreen()),
                      (r) => false,
                    ),
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