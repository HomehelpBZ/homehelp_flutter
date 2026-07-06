import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/language_provider.dart';
import 'hk_signin_screen.dart';
import 'registration/step1_personal.dart';

class HkSignupScreen extends StatelessWidget {
  const HkSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final steps = [
      (Icons.person_outline, s.stepPersonal),
      (Icons.school_outlined, s.stepBackground),
      (Icons.build_outlined, s.stepSkills),
      (Icons.work_outline, s.stepJobPrefs),
      (Icons.badge_outlined, s.stepIdVerify),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppTheme.primary,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(alignment: Alignment.topRight, child: const LangToggleButton()),
                const SizedBox(height: 8),
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person_add_outlined, size: 26, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(s.hkSignupTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(s.hkSignupSubtitle,
                    style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12),
                    textAlign: TextAlign.center),
                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                            child: Icon(step.$1, size: 13, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(step.$2, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Step1Personal())),
                    child: Text(s.hkSignupCreateBtn,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 14),

                Row(children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.2), thickness: 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(s.hkSignupAlreadyHave,
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.2), thickness: 0.5)),
                ]),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.35), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HkSigninScreen())),
                    child: Text(s.hkSignupSignIn),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.backHome,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
