import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/admin_service.dart';

class AdminReviewScreen extends StatefulWidget {
  final String housekeeperId;
  final VoidCallback onActionComplete;

  const AdminReviewScreen({
    super.key,
    required this.housekeeperId,
    required this.onActionComplete,
  });

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _guarantor;
  bool _isLoading = true;
  bool _isActing = false;
  String? _selectedReason;
  final _noteController = TextEditingController();
  bool _showRejectForm = false;

  static const rejectionReasons = [
    'ID photo is blurry or unreadable',
    'Selfie does not match ID',
    'Fayda ID number mismatch',
    'Incomplete profile information',
    'Guarantor could not be verified',
    'Suspicious or fraudulent document',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      final profile =
          await _adminService.getHkProfile(widget.housekeeperId);
      final guarantor =
          await _adminService.getGuarantor(widget.housekeeperId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _guarantor = guarantor;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _approve() async {
    setState(() => _isActing = true);
    try {
      final adminId =
          FirebaseAuth.instance.currentUser?.uid ?? 'admin';
      await _adminService.approveHk(
          uid: widget.housekeeperId, adminId: adminId);
      widget.onActionComplete();
      if (mounted) {
        showSuccessToast(context, 'Profile approved! HK notified.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to approve. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _reject() async {
    if (_selectedReason == null) return;
    setState(() => _isActing = true);
    try {
      final adminId =
          FirebaseAuth.instance.currentUser?.uid ?? 'admin';
      await _adminService.rejectHk(
        uid: widget.housekeeperId,
        adminId: adminId,
        reason: _selectedReason!,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      widget.onActionComplete();
      if (mounted) {
        showSuccessToast(context, 'Profile rejected. HK notified.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reject. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final p = _profile ?? {};
    final g = _guarantor ?? {};
    final name = p['fullName'] as String? ?? 'Unknown';
    final phone = p['phone'] as String? ?? '';
    final region = p['region'] as String? ?? '';
    final age = p['ageRange'] as String? ?? '';
    final gender = p['gender'] as String? ?? '';
    final education = p['education'] as String? ?? '';
    final experience = p['experienceYears'] as String? ?? '';
    final faydaId = p['faydaId'] as String? ?? 'Not provided';
    final skills = (p['skills'] as List?)?.cast<String>() ?? [];
    final languages = (p['languages'] as List?)?.cast<String>() ?? [];
    final jobTypes = (p['jobTypes'] as List?)?.cast<String>() ?? [];
    final arrangement = p['availability']?['arrangement'] as String? ?? '';
    final areas =
        (p['preferredAreas'] as List?)?.cast<String>() ?? [];
    final salary = p['rates']?['monthlyRate'] as String? ?? '';

    final gName = g['fullName'] as String? ?? '';
    final gPhone = g['phone'] as String? ?? '';
    final gRelation = g['relationship'] as String? ?? '';

    return Scaffold(
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(children: const [
                      Icon(Icons.arrow_back,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 4),
                      Text('Back',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        Text('+251$phone · $region',
                            style: const TextStyle(
                                color: Color(0xAAFFFFFF), fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amberLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Pending review',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.amber)),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal info
                  _Section(
                    title: 'Personal Information',
                    children: [
                      _InfoRow('Full name', name),
                      _InfoRow('Phone', '+251$phone'),
                      _InfoRow('Region', region),
                      _InfoRow('Age range', age),
                      _InfoRow('Gender', gender),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Background
                  _Section(
                    title: 'Background',
                    children: [
                      _InfoRow('Education', education),
                      _InfoRow('Experience', experience),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Skills
                  _Section(
                    title: 'Skills & Languages',
                    children: [
                      _ChipsRow('Skills', skills),
                      _ChipsRow('Languages', languages),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Job preferences
                  _Section(
                    title: 'Job Preferences',
                    children: [
                      _ChipsRow('Job types', jobTypes),
                      _InfoRow('Arrangement', arrangement),
                      _ChipsRow('Preferred areas', areas),
                      _InfoRow('Expected salary', '$salary Birr/month'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ID verification
                  _Section(
                    title: 'ID Verification',
                    children: [
                      _InfoRow('Fayda ID', faydaId),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: const [
                          Icon(Icons.info_outline,
                              size: 14, color: AppTheme.primary),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Document images (Firebase Storage) will be shown here after upgrading to Blaze plan.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryText),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Guarantor
                  _Section(
                    title: 'Guarantor (ተያዥ)',
                    children: [
                      _InfoRow('Full name', gName),
                      _InfoRow('Phone', '+251$gPhone'),
                      _InfoRow('Relationship', gRelation),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.amberLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: const [
                          Icon(Icons.phone_outlined,
                              size: 14, color: AppTheme.amber),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Call guarantor to verify before approving.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF633806)),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Reject form
                  if (_showRejectForm) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        border: Border.all(
                            color: AppTheme.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rejection reason *',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.grey800)),
                          const SizedBox(height: 8),
                          ...rejectionReasons.map((r) => GestureDetector(
                                onTap: () => setState(
                                    () => _selectedReason = r),
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedReason == r
                                        ? const Color(0xFFFFEBEB)
                                        : Colors.white,
                                    border: Border.all(
                                      color: _selectedReason == r
                                          ? AppTheme.red
                                          : AppTheme.grey200,
                                      width: 0.5,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Row(children: [
                                    Radio<String>(
                                      value: r,
                                      groupValue: _selectedReason,
                                      onChanged: (v) => setState(
                                          () => _selectedReason = v),
                                      activeColor: AppTheme.red,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize
                                              .shrinkWrap,
                                      visualDensity:
                                          VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Text(r,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.grey800))),
                                  ]),
                                ),
                              )),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText:
                                  'Optional note to housekeeper...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(
                                    () => _showRejectForm = false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.red),
                                onPressed:
                                    _selectedReason != null && !_isActing
                                        ? _reject
                                        : null,
                                child: _isActing
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Send rejection'),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  if (!_showRejectForm) ...[
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close,
                              size: 16, color: AppTheme.red),
                          label: const Text('Reject',
                              style: TextStyle(color: AppTheme.red)),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(
                                color: Color(0xFFF09595)),
                          ),
                          onPressed: () =>
                              setState(() => _showRejectForm = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: _isActing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Text('Approve profile'),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13)),
                          onPressed: _isActing ? null : _approve,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey600,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.grey200, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: Row(children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.grey600)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey800),
          ),
        ),
      ]),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final String label;
  final List<String> items;
  const _ChipsRow(this.label, this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.grey600)),
          ),
          Expanded(
            child: items.isEmpty
                ? const Text('—',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.grey800))
                : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: items
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.primaryText,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
