import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../models/hire.dart';
import '../services/hire_service.dart';

// 1/11/2026 — day first, as dates are usually written in Ethiopia.
String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

// 5000 → 5,000
String formatBirr(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

String hireSummaryText(Hire hire, AppStrings s) =>
    s.hireSummary(formatDate(hire.startDate), formatBirr(hire.monthlySalary));

// Asks the user to confirm; resolves to true only if they tap [confirmLabel].
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 17)),
      content: Text(body,
          style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: destructive
              ? ElevatedButton.styleFrom(backgroundColor: AppTheme.red)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Hire notices in a chat, shown in the reader's language.
String? hireNoticeLabel(String? kind, AppStrings s) {
  switch (kind) {
    case HireService.noticeRequested:
      return s.noticeHireRequestedShort;
    case HireService.noticeAccepted:
      return s.noticeHireAccepted;
    case HireService.noticeDeclined:
      return s.noticeHireDeclined;
    case HireService.noticeCancelled:
      return s.noticeHireCancelled;
    default:
      return null;
  }
}

class HireNoticeChip extends StatelessWidget {
  final String label;
  const HireNoticeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.amberLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.handshake_outlined, size: 13, color: AppTheme.amber),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF633806), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// The strip above the message box showing the hire's status and actions.
class HireStatusBar extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const HireStatusBar({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: AppTheme.primaryLight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w500,
                      height: 1.4)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppTheme.primaryText, height: 1.4)),
            ]),
          ),
        ]),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: actions,
          ),
        ],
      ]),
    );
  }
}

// Small buttons used in the hire strip.
Widget hireBarButton(String label, VoidCallback? onPressed, {bool primary = false}) {
  const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  const textStyle = TextStyle(fontSize: 12);
  return primary
      ? ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              padding: padding, textStyle: textStyle, minimumSize: Size.zero),
          child: Text(label))
      : OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
              padding: padding, textStyle: textStyle, minimumSize: Size.zero),
          child: Text(label));
}
