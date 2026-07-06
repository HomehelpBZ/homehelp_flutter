import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../welcome_screen.dart';

class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  bool _notifyMessages = true;
  bool _notifyNewHk = false;
  bool _emailUpdates = true;

  void _signOut(s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.settingsSignOut,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(s.settingsSignOutConfirm, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: const TextStyle(color: AppTheme.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (r) => false,
            ),
            child: Text(s.settingsSignOut),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      appBar: navyAppBar(s.settings),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account
            _SettingsCard(
              title: s.settingsAccount,
              children: [
                _InfoTile(icon: Icons.person_outline, label: s.settingsName, value: 'Abebe Kebede'),
                const Divider(height: 0),
                _InfoTile(icon: Icons.phone_outlined, label: s.settingsPhone, value: '+251 91 000 0001'),
                const Divider(height: 0),
                _NavTile(
                  icon: Icons.edit_outlined,
                  label: s.settingsEditAccount,
                  onTap: () => showSuccessToast(context, s.settingsAccountEditSoon),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Notifications
            _SettingsCard(
              title: s.settingsNotificationsSection,
              children: [
                _ToggleTile(
                  icon: Icons.message_outlined,
                  label: s.settingsFamilyMessages,
                  subtitle: s.settingsFamilyMessagesSub,
                  value: _notifyMessages,
                  onChanged: (v) => setState(() => _notifyMessages = v),
                ),
                const Divider(height: 0),
                _ToggleTile(
                  icon: Icons.person_add_outlined,
                  label: s.settingsNewHk,
                  subtitle: s.settingsNewHkSub,
                  value: _notifyNewHk,
                  onChanged: (v) => setState(() => _notifyNewHk = v),
                ),
                const Divider(height: 0),
                _ToggleTile(
                  icon: Icons.email_outlined,
                  label: s.settingsEmailUpdates,
                  subtitle: s.settingsEmailUpdatesSub,
                  value: _emailUpdates,
                  onChanged: (v) => setState(() => _emailUpdates = v),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Language
            _SettingsCard(
              title: s.settingsLanguage,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.language, size: 18, color: AppTheme.grey600),
                        const SizedBox(width: 12),
                        Text(s.settingsDisplayLanguage,
                            style: const TextStyle(fontSize: 13, color: AppTheme.grey800)),
                      ]),
                      const LangToggleFull(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // About
            _SettingsCard(
              title: s.settingsAbout,
              children: [
                _NavTile(icon: Icons.info_outline, label: s.settingsVersion, onTap: () {}),
                const Divider(height: 0),
                _NavTile(icon: Icons.privacy_tip_outlined, label: s.settingsPrivacy, onTap: () {}),
                const Divider(height: 0),
                _NavTile(icon: Icons.description_outlined, label: s.settingsTerms, onTap: () {}),
              ],
            ),
            const SizedBox(height: 20),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, size: 16, color: AppTheme.red),
                label: Text(s.settingsSignOut,
                    style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFF09595)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _signOut(s),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                  color: AppTheme.grey600, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.grey200, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTheme.grey400),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
      ]),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label,
      required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTheme.grey400),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey800)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
      ]),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 18, color: AppTheme.grey400),
      title: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey800)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.grey400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
    );
  }
}
