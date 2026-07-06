import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'l10n/language_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const HomeHelpApp());
}

class HomeHelpApp extends StatefulWidget {
  const HomeHelpApp({super.key});

  @override
  State<HomeHelpApp> createState() => _HomeHelpAppState();
}

class _HomeHelpAppState extends State<HomeHelpApp> {
  late final LanguageNotifier langNotifier;

  @override
  void initState() {
    super.initState();
    langNotifier = LanguageNotifier();
  }

  @override
  Widget build(BuildContext context) {
        return LanguageProvider(
      notifier: langNotifier,
      child: ListenableBuilder(
        listenable: langNotifier,
        builder: (context, _) => MaterialApp(
          title: 'HomeHelp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const WelcomeScreen(),
        ),
      ),
    );
  }
}
