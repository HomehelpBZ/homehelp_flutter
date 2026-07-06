import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'family_auth_screen.dart';

class PostJobScreen extends StatefulWidget {
  final bool isEditing;
  final bool isGuest; // Fix 4 — guest restriction
  const PostJobScreen({super.key, this.isEditing = false, this.isGuest = false});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  int? _selectedJobTypeIndex;
  String? _arrangement;
  final Map<int, bool> _days = {0:true,1:true,2:true,3:true,4:true,5:false,6:false};

  // Fix 2 — index-based area to survive language switch
  int? _selectedAreaIndex;

  final _salaryController = TextEditingController();
  DateTime? _selectedDate; // Fix 1 — proper date object
  final _descController = TextEditingController();

  bool get _isValid =>
      _selectedJobTypeIndex != null &&
      _arrangement != null &&
      _selectedAreaIndex != null &&
      _salaryController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _salaryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fix 1 — calendar date picker
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Fix 1 — format date as DD/MM/YYYY
  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  void _submit(s) {
    showSuccessToast(context, widget.isEditing ? s.jobUpdatedSuccess : s.jobPostedSuccess);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);

    // Fix 4 — show gate dialog if guest
    if (widget.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGuestGate(context, s);
      });
    }

    final jobTypes = s.jobTypeOptions;
    final arrangements = s.arrangementOptions;
    final dayLabels = s.dayLabels;
    final areaOptions = s.areaOptions; // Fix 2 — translated list

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? s.editJob : s.postJobTitle),
        actions: const [LangToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.postJobSubtitle,
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryText, height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Job type
            SectionLabel(s.jobTitle),
            ...List.generate(jobTypes.length, (i) => GestureDetector(
              onTap: () => setState(() => _selectedJobTypeIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedJobTypeIndex == i ? AppTheme.primaryLight : Colors.white,
                  border: Border.all(
                    color: _selectedJobTypeIndex == i ? AppTheme.primary : AppTheme.grey200,
                    width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Radio<int>(
                    value: i,
                    groupValue: _selectedJobTypeIndex,
                    onChanged: (v) => setState(() => _selectedJobTypeIndex = v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(jobTypes[i],
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey800))),
                ]),
              ),
            )),
            const SizedBox(height: 16),

            // Work arrangement
            SectionLabel(s.workArrangement),
            ...arrangements.map((arr) => GestureDetector(
              onTap: () => setState(() => _arrangement = arr.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _arrangement == arr.$1 ? AppTheme.primaryLight : Colors.white,
                  border: Border.all(
                    color: _arrangement == arr.$1 ? AppTheme.primary : AppTheme.grey200,
                    width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Radio<String>(
                    value: arr.$1,
                    groupValue: _arrangement,
                    onChanged: (v) => setState(() => _arrangement = v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(arr.$2,
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey800))),
                ]),
              ),
            )),
            const SizedBox(height: 16),

            // Working days
            SectionLabel(s.workingDays),
            Text(s.workingDaysNote,
                style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 5,
              children: List.generate(7, (i) => DayPill(
                day: dayLabels[i],
                isSelected: _days[i] ?? false,
                onTap: () => setState(() => _days[i] = !(_days[i] ?? false)),
              )),
            ),
            const SizedBox(height: 16),

            // Fix 2 + 3 — index-based area with "Any area" as first option
            SectionLabel(s.preferredArea),
            DropdownButtonFormField<int>(
              value: _selectedAreaIndex,
              hint: Text(s.anyArea,
                  style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: [
                // Fix 3 — "Any area" as actual selectable item
                DropdownMenuItem<int>(
                  value: -1,
                  child: Text(s.anyArea,
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey600)),
                ),
                // Fix 2 — use index, display translated string
                ...List.generate(areaOptions.length, (i) => DropdownMenuItem<int>(
                  value: i,
                  child: Text(areaOptions[i],
                      style: const TextStyle(fontSize: 13, color: AppTheme.grey800)),
                )),
              ],
              onChanged: (v) => setState(() => _selectedAreaIndex = v),
            ),
            const SizedBox(height: 16),

            // Salary
            SectionLabel(s.jobSalaryOffer),
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: s.jobSalaryHint,
                suffixText: 'Birr',
                suffixStyle: const TextStyle(color: AppTheme.grey600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),

            // Fix 1 — calendar date picker with DD/MM/YYYY
            SectionLabel(s.jobStartDate),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _selectedDate != null ? AppTheme.primary : const Color(0xFFE0E0E0),
                    width: _selectedDate != null ? 1.5 : 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16,
                      color: _selectedDate != null ? AppTheme.primary : AppTheme.grey400),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'DD/MM/YYYY',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedDate != null ? AppTheme.grey800 : AppTheme.grey400,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = null),
                      child: const Icon(Icons.close, size: 16, color: AppTheme.grey400),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 4),
            Text('Tap to open calendar',
                style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
            const SizedBox(height: 16),

            // Description
            Row(children: [
              SectionLabel(s.jobDescription),
              Text(s.optional,
                  style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
            ]),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(hintText: s.jobDescriptionHint),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: widget.isEditing ? s.saveChanges : s.postJob,
              onPressed: _isValid ? () => _submit(s) : null,
            ),
            const SizedBox(height: 10),
            SecondaryButton(label: s.cancel, onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Fix 4 — guest gate dialog
  void _showGuestGate(BuildContext context, dynamic s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey200,
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, size: 28, color: AppTheme.primary),
            ),
            const SizedBox(height: 14),
            Text(s.guestPostJobTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.grey800),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(s.guestPostJobSubtitle,
                style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close bottom sheet
                  Navigator.pop(context); // close post job screen
                  // Navigate to family auth screen (sign up tab)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyAuthScreen()),
                    (route) => false,
                  );
                },
                child: Text(s.createAccount),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // close bottom sheet
                  Navigator.pop(context); // close post job screen
                  // Navigate to family auth screen (sign in tab)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyAuthScreen()),
                    (route) => false,
                  );
                },
                child: Text(s.signInBtn),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancel,
                  style: const TextStyle(color: AppTheme.grey600)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
