import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../l10n/language_provider.dart';
import 'housekeeper/hk_auth_screen.dart';
import 'family/family_auth_screen.dart';
import 'family/family_home_screen.dart';
import 'admin/admin_login_screen.dart';
import '../widgets/welcome_illustrations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _isScrolled = _scrollController.offset > 50);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSignInOptions(BuildContext context, dynamic s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(s.signInBtn,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text('Choose your account type',
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 24),
            _SignInOption(
              icon: Icons.search,
              title: s.welcomeHireTitle,
              subtitle: 'Sign in to your family account',
              color: AppTheme.primary,
              bgColor: AppTheme.primaryLight,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FamilySignInScreen()));
              },
            ),
            const SizedBox(height: 10),
            _SignInOption(
              icon: Icons.person_outline,
              title: s.welcomeHkTitle,
              subtitle: 'Sign in to your housekeeper account',
              color: AppTheme.grey800,
              bgColor: const Color(0xFFF8FAFC),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HkSignInScreen()));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _isScrolled
              ? AppTheme.primary.withOpacity(0.95)
              : Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.home_outlined,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text('HomeHelp',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ]),
                  Row(children: [
                    const LangToggleFull(),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showSignInOptions(context, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(s.signInBtn,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ── Section 1: Hero ───────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF283593),
                    Color(0xFF1565C0),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 60),
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.home_outlined,
                        size: 46, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(s.welcomeAppName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1)),
                  const SizedBox(height: 10),
                  Text(s.welcomeTagline,
                      style: const TextStyle(
                          color: Color(0xCCFFFFFF), fontSize: 16),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0x66FFFFFF)),
                    const SizedBox(width: 4),
                    Text(s.welcomeCity,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13)),
                  ]),
                  const SizedBox(height: 24),
                  const HeroIllustration(),
                  const SizedBox(height: 24),

                  // CTA buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const FamilyHomeScreen(isGuest: true))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, size: 18),
                            const SizedBox(width: 8),
                            Text(s.welcomeHireTitle,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HkAuthScreen())),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(s.welcomeHkTitle,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(s.alreadyHaveAccount,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showSignInOptions(context, s),
                      child: Text(s.signInBtn,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white)),
                    ),
                  ]),
                ],
              ),
            ),

            // ── Section 2: How it works ───────────────────────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                _SectionTitle(
                    title: s.howItWorksTitle,
                    subtitle: s.howItWorksSubtitle),
                const SizedBox(height: 16),
                const HowItWorksIllustration(),
                const SizedBox(height: 16),
                _HowItWorksStep(
                  number: '1',
                  icon: Icons.search,
                  title: s.howStep1Title,
                  description: s.howStep1Desc,
                ),
                _HowItWorksStep(
                  number: '2',
                  icon: Icons.verified_user_outlined,
                  title: s.howStep2Title,
                  description: s.howStep2Desc,
                ),
                _HowItWorksStep(
                  number: '3',
                  icon: Icons.handshake_outlined,
                  title: s.howStep3Title,
                  description: s.howStep3Desc,
                  isLast: true,
                ),
              ]),
            ),

            // ── Section 3: Why HomeHelp ───────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                _SectionTitle(
                    title: s.whyHomehelpTitle,
                    subtitle: s.whyHomehelpSubtitle),
                const SizedBox(height: 20),
                const TrustIllustration(),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: _FeatureCard(
                          icon: Icons.badge_outlined,
                          title: s.feature1Title,
                          desc: s.feature1Desc)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _FeatureCard(
                          icon: Icons.people_outline,
                          title: s.feature2Title,
                          desc: s.feature2Desc)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _FeatureCard(
                          icon: Icons.star_outline,
                          title: s.feature3Title,
                          desc: s.feature3Desc)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _FeatureCard(
                          icon: Icons.lock_outline,
                          title: s.feature4Title,
                          desc: s.feature4Desc)),
                ]),
              ]),
            ),

            // ── Section 4: For Housekeepers ───────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                const HousekeeperIllustration(),
                const SizedBox(height: 16),
                Text(s.hkSectionTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(s.hkSectionSubtitle,
                    style: const TextStyle(
                        color: Color(0xCCFFFFFF), fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ...[
                  s.hkBenefit1,
                  s.hkBenefit2,
                  s.hkBenefit3,
                ].map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(b,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13))),
                      ]),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HkAuthScreen())),
                    child: Text(s.hkSectionCta,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),

            // ── Section 5: Stats ──────────────────────────────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatBadge(value: '100%', label: s.statVerified),
                  _Divider(),
                  _StatBadge(value: '0', label: s.statFee),
                  _Divider(),
                  _StatBadge(value: s.statCityValue, label: s.statCity),
                ],
              ),
              ]),
            ),

            // ── Footer ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF1A237E),
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home_outlined,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text('HomeHelp',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 12),
                Text(s.welcomeTagline,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 16),
                const Divider(color: Color(0x33FFFFFF)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen())),
                  child: Text(s.welcomeFooter,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 11),
                      textAlign: TextAlign.center),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(title,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey800),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(subtitle,
          style: const TextStyle(fontSize: 13, color: AppTheme.grey600),
          textAlign: TextAlign.center),
    ]);
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;
  const _HowItWorksStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (!isLast)
            Container(
                width: 2, height: 40, color: AppTheme.grey200),
        ]),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.grey800)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey600,
                          height: 1.5)),
                ]),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey800)),
        const SizedBox(height: 4),
        Text(desc,
            style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
      ]),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary)),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppTheme.grey600),
          textAlign: TextAlign.center),
    ]);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppTheme.grey200);
  }
}

class _SignInOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _SignInOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.grey800)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.grey600)),
          ]),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppTheme.grey400),
        ]),
      ),
    );
  }
}