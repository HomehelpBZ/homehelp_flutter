import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../welcome_screen.dart';

class HkSettingsScreen extends StatefulWidget {
  const HkSettingsScreen({super.key});

  @override
  State<HkSettingsScreen> createState() => _HkSettingsScreenState();
}

class _HkSettingsScreenState extends State<HkSettingsScreen> {
  bool _notifyMessages = true;
  bool _notifyViews = true;
  bool _notifyApprovals = true;
  bool _profileVisible = true;
  bool _showPhone = false;

  void _signOut(s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.settingsSignOut,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(s.settingsSignOutConfirm,
            style: const TextStyle(fontSize: 14)),
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
                _InfoTile(icon: Icons.person_outline, label: s.settingsName, value: 'Tigist Bekele'),
                const Divider(height: 0),
                _InfoTile(icon: Icons.phone_outlined, label: s.settingsPhone, value: '+251 91 234 5678'),
                const Divider(height: 0),
                _InfoTile(icon: Icons.badge_outlined, label: s.settingsFaydaId, value: 'ETH-2024-00183721'),
                const Divider(height: 0),
                _InfoTile(icon: Icons.verified_user_outlined,
                    label: s.settingsVerification,
                    value: s.settingsVerified,
                    valueColor: AppTheme.primary),
              ],
            ),
            const SizedBox(height: 14),

            // Profile visibility
            _SettingsCard(
              title: s.settingsProfile,
              children: [
                _ToggleTile(
                  icon: Icons.visibility_outlined,
                  label: s.settingsProfileVisible,
                  subtitle: s.settingsProfileVisibleSub,
                  value: _profileVisible,
                  onChanged: (v) => setState(() => _profileVisible = v),
                ),
                const Divider(height: 0),
                _ToggleTile(
                  icon: Icons.phone_outlined,
                  label: s.settingsShowPhone,
                  subtitle: s.settingsShowPhoneSub,
                  value: _showPhone,
                  onChanged: (v) => setState(() => _showPhone = v),
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
                  label: s.settingsNewMessages,
                  subtitle: s.settingsNewMessagesSub,
                  value: _notifyMessages,
                  onChanged: (v) => setState(() => _notifyMessages = v),
                ),
                const Divider(height: 0),
                _ToggleTile(
                  icon: Icons.visibility_outlined,
                  label: s.settingsProfileViews,
                  subtitle: s.settingsProfileViewsSub,
                  value: _notifyViews,
                  onChanged: (v) => setState(() => _notifyViews = v),
                ),
                const Divider(height: 0),
                _ToggleTile(
                  icon: Icons.check_circle_outline,
                  label: s.settingsApprovalUpdates,
                  subtitle: s.settingsApprovalUpdatesSub,
                  value: _notifyApprovals,
                  onChanged: (v) => setState(() => _notifyApprovals = v),
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

            // Security
            _SettingsCard(
              title: s.settingsSecurity,
              children: [
                _NavTile(
                  icon: Icons.lock_outline,
                  label: s.settingsChangePassword,
                  onTap: () => showSuccessToast(context, s.settingsPasswordSent),
                ),
                const Divider(height: 0),
                _NavTile(
                  icon: Icons.delete_outline,
                  label: s.settingsDeleteAccount,
                  labelColor: AppTheme.red,
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(s.settingsDeleteAccount,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      content: Text(s.settingsDeleteAccountMsg),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(s.cancel, style: const TextStyle(color: AppTheme.grey600)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
                          onPressed: () {},
                          child: Text(s.settingsDelete),
                        ),
                      ],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
  final Color? valueColor;
  const _InfoTile({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: AppTheme.grey400),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grey600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: valueColor ?? AppTheme.grey800)),
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
  final Color? labelColor;
  final VoidCallback onTap;
  const _NavTile({required this.icon, required this.label, this.labelColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 18, color: labelColor ?? AppTheme.grey400),
      title: Text(label, style: TextStyle(fontSize: 13, color: labelColor ?? AppTheme.grey800)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.grey400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
    );
  }
}
