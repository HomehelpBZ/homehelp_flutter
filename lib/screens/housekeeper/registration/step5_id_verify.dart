import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../l10n/language_provider.dart';
import '../../../services/user_service.dart';
import 'step6_guarantor.dart';

class Step5IdVerify extends StatefulWidget {
  const Step5IdVerify({super.key});

  @override
  State<Step5IdVerify> createState() => _Step5IdVerifyState();
}

class _Step5IdVerifyState extends State<Step5IdVerify> {
  final _faydaController = TextEditingController();
  Uint8List? _frontBytes;
  Uint8List? _backBytes;
  Uint8List? _selfieBytes;
  final UserService _userService = UserService();
  bool _isSaving = false;

  bool get _isValid =>
      _faydaController.text.trim().isNotEmpty &&
      _frontBytes != null &&
      _selfieBytes != null;

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (type == 'front') _frontBytes = bytes;
        if (type == 'back') _backBytes = bytes;
        if (type == 'selfie') _selfieBytes = bytes;
      });
    }
  }

  @override
  void dispose() {
    _faydaController.dispose();
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
                  StepProgressBar(currentStep: 5, totalSteps: 6),
                  const SizedBox(height: 10),
                  Text(s.verifyIdentity,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(5, 6),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 15, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s.idPrivacyNote,
                            style: const TextStyle(fontSize: 11, color: AppTheme.primaryText, height: 1.5))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.badge_outlined, size: 13, color: AppTheme.primary),
                          const SizedBox(width: 5),
                          Text(s.faydaIdLabel,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.grey600)),
                        ]),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _faydaController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(hintText: s.faydaIdHint),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionLabel(s.frontId),
                  _UploadBox(
                    bytes: _frontBytes, icon: Icons.credit_card,
                    title: s.uploadFrontId, subtitle: s.uploadFrontSub,
                    onTap: () => _pickImage('front'),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    SectionLabel(s.backId),
                    Text(s.optional, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                  ]),
                  _UploadBox(
                    bytes: _backBytes, icon: Icons.credit_card,
                    title: s.uploadBackId, subtitle: s.uploadBackSub,
                    onTap: () => _pickImage('back'),
                  ),
                  const SizedBox(height: 10),
                  SectionLabel(s.selfieLabel),
                  _UploadBox(
                    bytes: _selfieBytes, icon: Icons.camera_alt_outlined,
                    title: s.uploadSelfie, subtitle: s.uploadSelfieSub,
                    onTap: () => _pickImage('selfie'),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: s.continueBtn,
                    isLoading: _isSaving,
                    onPressed: _isValid && !_isSaving
                        ? () async {
                            setState(() => _isSaving = true);
                            try {
                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              if (uid != null) {
                                // Note: In production, upload images to Firebase Storage
                                // and save the download URLs. For MVP, save Fayda ID only.
                                await _userService.saveHkDocuments(
                                  uid: uid,
                                  faydaId: _faydaController.text.trim(),
                                );
                              }
                            } catch (e) {
                              // Continue even if save fails
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
                            if (mounted) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const Step6Guarantor()));
                            }
                          }
                        : null,
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

class _UploadBox extends StatelessWidget {
  final Uint8List? bytes;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _UploadBox({required this.bytes, required this.icon,
      required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uploaded = bytes != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: uploaded ? AppTheme.primaryLight : Colors.white,
          border: Border.all(
            color: uploaded ? AppTheme.primary : const Color(0xFFBDBDBD),
            width: uploaded ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: uploaded
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.memory(bytes!,
                        height: 100, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 14, color: AppTheme.primary),
                        SizedBox(width: 5),
                        Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primary)),
                      ],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Column(
                  children: [
                    Icon(icon, size: 24, color: AppTheme.grey400),
                    const SizedBox(height: 7),
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                  ],
                ),
              ),
      ),
    );
  }
}