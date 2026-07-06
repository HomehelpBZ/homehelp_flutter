import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../l10n/language_provider.dart';
import '../hk_dashboard_screen.dart';

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
  bool _submitted = false;

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
    if (_submitted) return _SubmittedScreen(s: s);

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
                  StepProgressBar(currentStep: 5, totalSteps: 5),
                  const SizedBox(height: 10),
                  Text(s.verifyIdentity,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(5, 5),
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
                    label: s.submitProfile,
                    onPressed: _isValid ? () => setState(() => _submitted = true) : null,
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

class _SubmittedScreen extends StatelessWidget {
  final dynamic s;
  const _SubmittedScreen({required this.s});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 34, color: AppTheme.primary),
              ),
              const SizedBox(height: 18),
              Text(s.profileSubmitted,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.grey800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(s.submittedNote,
                  style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.6),
                  textAlign: TextAlign.center),
              const SizedBox(height: 22),
              ...[
                (Icons.check, 'Profile created', 'All details saved', true),
                (Icons.check, 'ID uploaded', 'Documents received', true),
                (Icons.access_time, 'Verification in progress', 'Usually 1–2 business days', false),
                (Icons.visibility_outlined, 'Visible to families', 'After approval', false),
              ].map((step) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: step.$4 ? AppTheme.primaryLight : AppTheme.amberLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.$1, size: 13,
                            color: step.$4 ? AppTheme.primary : AppTheme.amber),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(step.$2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                        Text(step.$3, style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                      ]),
                    ]),
                  )),
              const SizedBox(height: 16),
              PrimaryButton(
                label: s.goToDashboard,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HkDashboardScreen()),
                  (r) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
