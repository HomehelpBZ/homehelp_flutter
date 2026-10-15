import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/hire_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/hire.dart';
import '../../services/hire_service.dart';

// Full-screen view of a hire request. The housekeeper must tap the accept
// button and then confirm, so a hire can't be accepted by accident.
class HireRequestScreen extends StatefulWidget {
  final Hire hire;
  final String familyName;
  const HireRequestScreen({super.key, required this.hire, required this.familyName});

  @override
  State<HireRequestScreen> createState() => _HireRequestScreenState();
}

class _HireRequestScreenState extends State<HireRequestScreen> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    final s = LanguageProvider.strings(context);
    final ok = await showConfirmDialog(
      context,
      title: accept ? s.acceptJobTitle : s.declineJobTitle,
      body: accept
          ? '${hireSummaryText(widget.hire, s)}\n\n${s.acceptJobNote(widget.familyName)}'
          : hireSummaryText(widget.hire, s),
      confirmLabel: accept ? s.yesAccept : s.yesDecline,
      cancelLabel: s.goBack,
      destructive: !accept,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await HireService().respond(
        familyUid: widget.hire.familyUid,
        hkUid: widget.hire.hkUid,
        accept: accept,
        noticeText: accept ? s.noticeHireAccepted : s.noticeHireDeclined,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // e.g. the family cancelled the request meanwhile.
      debugPrint('Hire response failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      showErrorToast(context, s.errGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final hire = widget.hire;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.hireRequestTitle),
        actions: const [LangToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.hireRequestIntro(widget.familyName),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.grey200, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(children: [
                InfoRow(label: s.hireStartDate, value: formatDate(hire.startDate)),
                const Divider(height: 0),
                InfoRow(
                    label: s.hireMonthlySalary,
                    value: '${formatBirr(hire.monthlySalary)} ${s.birr}'),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.amberLight, borderRadius: BorderRadius.circular(8)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_outlined, size: 16, color: AppTheme.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.hireRequestWarning,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF633806), height: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _busy ? s.loading : s.acceptJob,
              onPressed: _busy ? null : () => _respond(true),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: s.declineJob,
              onPressed: _busy ? null : () => _respond(false),
            ),
          ],
        ),
      ),
    );
  }
}
