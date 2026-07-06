import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/language_provider.dart';
import 'housekeeper/hk_signup_screen.dart';
import '../screens/family/family_auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppTheme.primary),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Language toggle top-right
                Align(
                  alignment: Alignment.topRight,
                  child: const LangToggleFull(),
                ),
                const Spacer(),

                // Logo
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.home_outlined, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 18),

                Text(s.welcomeAppName,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(s.welcomeTagline,
                    style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0x66FFFFFF)),
                    const SizedBox(width: 4),
                    Text(s.welcomeCity,
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  ],
                ),

                const Spacer(),

                _PathCard(
                  icon: Icons.search,
                  title: s.welcomeHireTitle,
                  subtitle: s.welcomeHireSubtitle,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FamilyAuthScreen())),
                ),
                const SizedBox(height: 12),
                _PathCard(
                  icon: Icons.person_add_outlined,
                  title: s.welcomeHkTitle,
                  subtitle: s.welcomeHkSubtitle,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HkSignupScreen())),
                ),

                const SizedBox(height: 28),
                Text(s.welcomeFooter,
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PathCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
