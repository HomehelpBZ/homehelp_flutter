import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/hire_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import '../../services/hire_service.dart';
import '../../services/user_service.dart';

// The family fills in the start date and monthly salary, confirms, and the
// request goes to the housekeeper to accept.
class HireFormScreen extends StatefulWidget {
  final Housekeeper hk;
  const HireFormScreen({super.key, required this.hk});

  @override
  State<HireFormScreen> createState() => _HireFormScreenState();
}

class _HireFormScreenState extends State<HireFormScreen> {
  final _salaryController = TextEditingController();
  DateTime? _startDate;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() { _startDate = picked; _error = null; });
  }

  Future<void> _submit() async {
    final s = LanguageProvider.strings(context);
    final salary = int.tryParse(_salaryController.text.trim()) ?? 0;
    if (_startDate == null) return setState(() => _error = s.errPickStartDate);
    if (salary <= 0) return setState(() => _error = s.errEnterSalary);
    setState(() => _error = null);

    final date = formatDate(_startDate!);
    final birr = formatBirr(salary);
    final ok = await showConfirmDialog(
      context,
      title: s.sendHireRequestTitle,
      body: '${widget.hk.name}\n${s.hireSummary(date, birr)}\n\n'
          '${s.hireFormNote(widget.hk.name.split(' ').first)}',
      confirmLabel: s.sendHireRequest,
      cancelLabel: s.goBack,
    );
    if (!ok || !mounted) return;

    setState(() => _sending = true);
    try {
      final familyUid = FirebaseAuth.instance.currentUser!.uid;
      final familyName = await UserService().getFamilyName(familyUid) ?? '';
      await HireService().requestHire(
        familyUid: familyUid,
        hkUid: widget.hk.id,
        familyName: familyName,
        hkName: widget.hk.name,
        startDate: _startDate!,
        monthlySalary: salary,
        noticeText: s.noticeHireRequested(date, birr),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Hire request failed (hk ${widget.hk.id}): $e');
      if (!mounted) return;
      setState(() => _sending = false);
      showErrorToast(context, s.errHireNotSent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final firstName = widget.hk.name.split(' ').first;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.hireTitle(firstName)),
        actions: const [LangToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(s.hireStartDate),
            InkWell(
              onTap: _sending ? null : _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(
                  _startDate == null ? s.selectDate : formatDate(_startDate!),
                  style: TextStyle(
                      fontSize: 14,
                      color: _startDate == null ? AppTheme.grey400 : AppTheme.grey800),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SectionLabel(s.hireMonthlySalary),
            TextField(
              controller: _salaryController,
              enabled: !_sending,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: const InputDecoration(hintText: '5000'),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.red)),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline, size: 15, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.hireFormNote(firstName),
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.primaryText, height: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: _sending ? s.loading : s.sendHireRequest,
              onPressed: _sending ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
