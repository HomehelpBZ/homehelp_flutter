// lib/l10n/language_provider.dart
// Provides language state to the entire widget tree

import 'package:flutter/material.dart';
import 'app_strings.dart';

class LanguageProvider extends InheritedNotifier<LanguageNotifier> {
  const LanguageProvider({
    super.key,
    required LanguageNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static LanguageNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<LanguageProvider>();
    assert(provider != null, 'No LanguageProvider found in context');
    return provider!.notifier!;
  }

  static AppStrings strings(BuildContext context) {
    return AppStrings(of(context).languageCode);
  }
}

class LanguageNotifier extends ChangeNotifier {
  String _languageCode = 'en'; // 'en' or 'am'

  String get languageCode => _languageCode;
  bool get isAmharic => _languageCode == 'am';

  void toggle() {
    _languageCode = _languageCode == 'en' ? 'am' : 'en';
    notifyListeners();
  }

  void setLanguage(String code) {
    if (_languageCode != code) {
      _languageCode = code;
      notifyListeners();
    }
  }
}

/// Compact toggle button — place in AppBar actions or anywhere in the UI
class LangToggleButton extends StatelessWidget {
  final Color? color;

  const LangToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final notifier = LanguageProvider.of(context);
    final isAmharic = notifier.isAmharic;

    return GestureDetector(
      onTap: notifier.toggle,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAmharic ? '🇬🇧' : '🇪🇹',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 5),
            Text(
              isAmharic ? 'EN' : 'አማ',
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full toggle for welcome screen (on dark background)
class LangToggleFull extends StatelessWidget {
  const LangToggleFull({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = LanguageProvider.of(context);
    final isAmharic = notifier.isAmharic;

    return GestureDetector(
      onTap: notifier.toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EN pill
            _LangPill(label: 'EN', flag: '🇬🇧', active: !isAmharic),
            const SizedBox(width: 6),
            // AM pill
            _LangPill(label: 'አማ', flag: '🇪🇹', active: isAmharic),
          ],
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final String flag;
  final bool active;

  const _LangPill({required this.label, required this.flag, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF1E3A8A) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
