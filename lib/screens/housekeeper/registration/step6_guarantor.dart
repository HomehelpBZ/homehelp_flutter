import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../l10n/language_provider.dart';
import '../hk_dashboard_screen.dart';

class Step6Guarantor extends StatefulWidget {
  const Step6Guarantor({super.key});

  @override
  State<Step6Guarantor> createState() => _Step6GuarantorState();
}

class _Step6GuarantorState extends State<Step6Guarantor> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _relationship;
  bool _submitted = false;

  static const relationships = [
    'Family member / የቤተሰብ አባል',
    'Neighbor / ጎረቤት',
    'Previous employer / የቀድሞ አሰሪ',
    'Friend / ጓደኛ',
    'Religious leader / የሃይማኖት መሪ',
    'Community leader / የማህበረሰብ መሪ',
  ];

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.length == 9 &&
      _relationship != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                          Icon(Icons.arrow_back,
                              color: Colors.white70, size: 18),
                          SizedBox(width: 4),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13)),
                        ]),
                      ),
                      const LangToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StepProgressBar(currentStep: 6, totalSteps: 6),
                  const SizedBox(height: 10),
                  Text(s.stepGuarantor,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  Text(s.stepLabel(6, 6),
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
                  // Info card
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
                          child: Text(s.guarantorNote,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF633806),
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full name
                  SectionLabel(s.guarantorName),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s\u1200-\u137F]'))
                    ],
                    decoration: InputDecoration(
                        hintText: s.guarantorNameHint),
                  ),
                  const SizedBox(height: 14),

                  // Phone number
                  SectionLabel(s.guarantorPhone),
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
                  const SizedBox(height: 14),

                  // Relationship
                  SectionLabel(s.guarantorRelationship),
                  ...relationships.map((r) => GestureDetector(
                        onTap: () =>
                            setState(() => _relationship = r),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _relationship == r
                                ? AppTheme.primaryLight
                                : Colors.white,
                            border: Border.all(
                              color: _relationship == r
                                  ? AppTheme.primary
                                  : AppTheme.grey200,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Radio<String>(
                              value: r,
                              groupValue: _relationship,
                              onChanged: (v) =>
                                  setState(() => _relationship = v),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(r,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.grey800))),
                          ]),
                        ),
                      )),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: s.submitProfile,
                    onPressed: _isValid
                        ? () => setState(() => _submitted = true)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                      label: s.backBtn,
                      onPressed: () => Navigator.pop(context)),
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

// ── Submitted screen ──────────────────────────────────────────────────────────
class _SubmittedScreen extends StatelessWidget {
  final dynamic s;
  const _SubmittedScreen({required this.s});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle),
                child: const Icon(Icons.check,
                    size: 34, color: AppTheme.primary),
              ),
              const SizedBox(height: 18),
              Text(s.profileSubmitted,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.grey800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(s.submittedNote,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.grey600,
                      height: 1.6),
                  textAlign: TextAlign.center),
              const SizedBox(height: 22),
              ...[
                (Icons.check, 'Profile created', 'All details saved', true),
                (Icons.check, 'ID uploaded', 'Documents received', true),
                (Icons.people_outline, 'Guarantor added',
                    'Admin will verify by phone call', true),
                (Icons.access_time, 'Verification in progress',
                    'Usually 1–2 business days', false),
                (Icons.visibility_outlined, 'Visible to families',
                    'After approval', false),
              ].map((step) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFEEEEEE), width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: step.$4
                              ? AppTheme.primaryLight
                              : AppTheme.amberLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.$1,
                            size: 13,
                            color: step.$4
                                ? AppTheme.primary
                                : AppTheme.amber),
                      ),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.$2,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.grey800)),
                            Text(step.$3,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.grey600)),
                          ]),
                    ]),
                  )),
              const SizedBox(height: 16),
              PrimaryButton(
                label: s.goToDashboard,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HkDashboardScreen()),
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