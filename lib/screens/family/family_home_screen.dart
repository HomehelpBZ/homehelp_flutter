import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/language_provider.dart';
import '../../services/auth_service.dart';
import 'browse_screen.dart';
import 'my_jobs_screen.dart';
import 'family_settings_screen.dart';
import 'family_messages_screen.dart';
import '../welcome_screen.dart';

class FamilyHomeScreen extends StatefulWidget {
  final bool isGuest;
  const FamilyHomeScreen({super.key, this.isGuest = false});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  int _tab = 0;
  final AuthService _authService = AuthService();

  void _signOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (r) => false,
                );
              }
            },
            child: const Text('Sign out'),
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
      // Show logout button only when signed in (not guest)
      floatingActionButton: !widget.isGuest
          ? null
          : null,
      body: Stack(
        children: [
          IndexedStack(
            index: _tab,
            children: [
              const BrowseScreen(showBackButton: false),
              MyJobsScreen(isGuest: widget.isGuest),
              const FamilyMessagesScreen(),
              const FamilySettingsScreen(),
            ],
          ),
          // Logout button — top right, only for signed in users
          if (!widget.isGuest)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: GestureDetector(
                onTap: _signOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    const Icon(Icons.logout, size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(s.settingsSignOut,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            label: s.browseTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            label: s.myJobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message_outlined),
            label: s.messages,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            label: s.settings,
          ),
        ],
      ),
    );
  }
}