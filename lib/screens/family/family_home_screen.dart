import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import 'browse_screen.dart';
import 'my_jobs_screen.dart';
import 'family_settings_screen.dart';
import 'family_messages_screen.dart';

class FamilyHomeScreen extends StatefulWidget {
  final bool isGuest;
  const FamilyHomeScreen({super.key, this.isGuest = false});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          const BrowseScreen(showBackButton: false),
          MyJobsScreen(isGuest: widget.isGuest),
          const FamilyMessagesScreen(),
          const FamilySettingsScreen(),
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
