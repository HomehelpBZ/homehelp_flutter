import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/language_provider.dart';

// ── Navy blue header used on most screens ──────────────────────────────────
class NavyHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? leading;

  const NavyHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.children = const [],
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[leading!, const SizedBox(height: 10)],
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(subtitle!,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Housekeeper avatar circle ────────────────────────────────────────────────
class HkAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final double fontSize;

  const HkAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 48,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(initials,
            style: TextStyle(
                color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ── Verified badge ───────────────────────────────────────────────────────────
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_user, size: 10, color: AppTheme.primary),
          SizedBox(width: 3),
          Text('Verified',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
        ],
      ),
    );
  }
}

// ── Skill chip ───────────────────────────────────────────────────────────────
class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
    );
  }
}

// ── Star rating row ──────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;

  const StarRating({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: starSize, color: const Color(0xFFEF9F27)),
        const SizedBox(width: 3),
        Text('$rating ($reviewCount)',
            style: TextStyle(fontSize: starSize - 1, color: AppTheme.grey600)),
      ],
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

// ── Secondary (outline) button ───────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.grey600,
              letterSpacing: 0.4)),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
        ],
      ),
    );
  }
}

// ── Step progress bar ─────────────────────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 5 : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// ── Day pill toggle ───────────────────────────────────────────────────────────
class DayPill extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const DayPill({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFDDDDDD),
            width: 2,
          ),
        ),
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.grey600,
          ),
        ),
      ),
    );
  }
}

// ── Safety note box ───────────────────────────────────────────────────────────
class SafetyNote extends StatelessWidget {
  final String text;

  const SafetyNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.amberLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: AppTheme.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 11, color: Color(0xFF633806), height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ── Toast / success banner ────────────────────────────────────────────────────
void showSuccessToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppTheme.primaryText))),
        ],
      ),
      backgroundColor: AppTheme.primaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Standard navy AppBar with language toggle always in actions
AppBar navyAppBar(String title, {List<Widget>? extraActions}) {
  return AppBar(
    title: Text(title),
    actions: [
      const LangToggleButton(),
      if (extraActions != null) ...extraActions,
    ],
  );
}
