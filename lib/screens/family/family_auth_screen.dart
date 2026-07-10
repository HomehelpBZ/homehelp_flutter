import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'browse_screen.dart';
import 'family_home_screen.dart';
import '../welcome_screen.dart';
import '../../services/auth_service.dart';

class FamilyAuthScreen extends StatefulWidget {
  const FamilyAuthScreen({super.key});

  @override
  State<FamilyAuthScreen> createState() => _FamilyAuthScreenState();
}

class _FamilyAuthScreenState extends State<FamilyAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 16),
                        label: Text(s.home, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (r) => false,
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                      const LangToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.search, size: 26, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(s.findAHousekeeper,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(s.familyAuthSubtitle,
                      style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      unselectedLabelStyle: const TextStyle(fontSize: 13),
                      tabs: [
                        Tab(text: s.signUp),
                        Tab(text: s.signIn),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_SignUpTab(), _SignInTab()],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
            ),
            child: Builder(builder: (context) {
              final s2 = LanguageProvider.strings(context);
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.search, size: 16),
                  label: Text(s2.browseWithoutAccount),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyHomeScreen(isGuest: true)),
                    (r) => false,
                  ),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SignUpTab extends StatefulWidget {
  const _SignUpTab();
  @override
  State<_SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<_SignUpTab> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPw = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.length == 10 &&
      _passwordController.text.length >= 6 &&
      _passwordController.text == _confirmController.text;

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose();
    _passwordController.dispose(); _confirmController.dispose();
    super.dispose();
  }

  void _signUp() async {
    _authService.currentUser;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const FamilyHomeScreen(isGuest: false)), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final pwMatch = _confirmController.text.isNotEmpty &&
        _passwordController.text == _confirmController.text;
    final pwMismatch = _confirmController.text.isNotEmpty &&
        _passwordController.text != _confirmController.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          SectionLabel(s.fullName),
          TextFormField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\u1200-\u137F]'))],
            decoration: InputDecoration(hintText: s.fullNameHint),
          ),
          const SizedBox(height: 14),
          SectionLabel(s.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: s.phoneHint, counterText: ''),
          ),
          const SizedBox(height: 14),
          SectionLabel(s.password),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPw,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: s.password,
              suffixIcon: IconButton(
                icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility,
                    size: 18, color: AppTheme.grey400),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SectionLabel(s.confirmPassword),
          TextFormField(
            controller: _confirmController,
            obscureText: !_showConfirm,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: s.confirmPassword,
              suffixIcon: IconButton(
                icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility,
                    size: 18, color: AppTheme.grey400),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (pwMatch) Row(children: [
            const Icon(Icons.check_circle, size: 13, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(s.passwordsMatch, style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
          ]),
          if (pwMismatch) Row(children: [
            const Icon(Icons.cancel, size: 13, color: AppTheme.red),
            const SizedBox(width: 4),
            Text(s.passwordsMismatch, style: const TextStyle(fontSize: 11, color: AppTheme.red)),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              _Benefit(icon: Icons.favorite_border, text: s.benefit1),
              const SizedBox(height: 8),
              _Benefit(icon: Icons.history, text: s.benefit2),
              const SizedBox(height: 8),
              _Benefit(icon: Icons.notifications_outlined, text: s.benefit3),
            ]),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: s.createAccount, onPressed: _isValid ? _signUp : null, isLoading: _isLoading),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SignInTab extends StatefulWidget {
  const _SignInTab();
  @override
  State<_SignInTab> createState() => _SignInTabState();
}

class _SignInTabState extends State<_SignInTab> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPw = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    _authService.currentUser;
    if (_phoneController.text.length < 10 || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const FamilyHomeScreen(isGuest: false)), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          SectionLabel(s.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: s.phoneHint, counterText: ''),
          ),
          const SizedBox(height: 14),
          SectionLabel(s.password),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPw,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: s.password,
              suffixIcon: IconButton(
                icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility,
                    size: 18, color: AppTheme.grey400),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: EdgeInsets.zero),
              child: Text(s.forgotPassword,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: s.signInBtn,
            onPressed: _phoneController.text.length == 10 && _passwordController.text.isNotEmpty
                ? _signIn : null,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: AppTheme.grey200, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.whenSignedIn,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
              const SizedBox(height: 8),
              _Benefit(icon: Icons.favorite_border, text: s.benefit4),
              const SizedBox(height: 6),
              _Benefit(icon: Icons.history, text: s.benefit5),
              const SizedBox(height: 6),
              _Benefit(icon: Icons.message_outlined, text: s.benefit6),
            ]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
          style: const TextStyle(fontSize: 12, color: AppTheme.primaryText))),
    ]);
  }
}
