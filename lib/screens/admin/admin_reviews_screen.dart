import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/hire_widgets.dart';
import '../../services/user_service.dart';

// Admins hide abusive reviews here. A removed review stays stored (with who
// removed it and why) but is no longer shown or counted in the rating.
class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final _svc = UserService();
  late final Stream<List<Map<String, dynamic>>> _reviews = _svc.watchAllReviews();
  final Map<String, Future<String?>> _hkNames = {};
  bool _showRemoved = false;
  bool? _isAdmin;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _svc.isAdmin(_uid).then((v) {
      if (mounted) setState(() => _isAdmin = v);
    });
  }

  Future<String?> _hkName(String uid) =>
      _hkNames.putIfAbsent(uid, () => _svc.getHkName(uid).catchError((_) => null));

  Future<void> _remove(Map<String, dynamic> review) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Remove this review?', style: TextStyle(fontSize: 17)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
                'It will be hidden from everyone and taken out of the '
                'housekeeper\'s rating. The family can\'t post it again.',
                style: TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              autofocus: true,
              maxLength: 200,
              decoration: const InputDecoration(
                  hintText: 'Reason (e.g. insults, false claims, personal info)'),
              onChanged: (_) => setDialogState(() {}),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
              onPressed: reasonController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(ctx, reasonController.text.trim()),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
    reasonController.dispose();
    if (reason == null) return;
    try {
      await _svc.removeReview(
          reviewDocId: review['id'] as String, adminUid: _uid, reason: reason);
    } catch (e) {
      debugPrint('Remove review failed: $e');
      if (mounted) showErrorToast(context, 'Review not removed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Column(children: [
        if (_isAdmin == false)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppTheme.amberLight,
            child: const Text(
              'This account is not set up as an admin, so removing reviews will '
              'fail. In the Firebase console, add a document to the "admins" '
              'collection with this account\'s user ID as the document ID.',
              style: TextStyle(fontSize: 12, color: Color(0xFF633806), height: 1.5),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            ChoiceChip(
              label: const Text('Visible'),
              selected: !_showRemoved,
              onSelected: (_) => setState(() => _showRemoved = false),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Removed'),
              selected: _showRemoved,
              onSelected: (_) => setState(() => _showRemoved = true),
            ),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _reviews,
            builder: (context, snap) {
              if (snap.hasError) {
                return const Center(child: Text('Error loading reviews'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final reviews = snap.data!
                  .where((r) => (r['removed'] == true) == _showRemoved)
                  .toList();
              if (reviews.isEmpty) {
                return Center(
                  child: Text(_showRemoved ? 'No removed reviews.' : 'No reviews yet.',
                      style: const TextStyle(color: AppTheme.grey400)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, i) => _card(reviews[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _card(Map<String, dynamic> r) {
    final stars = (r['starRating'] as num?)?.toInt() ?? 0;
    final date = (r['createdAt'] as Timestamp?)?.toDate();
    final text = (r['reviewText'] as String?)?.trim() ?? '';
    final reply = (r['response'] as Map?)?['text'] as String?;
    final removed = r['removed'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.grey200, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FutureBuilder<String?>(
          future: _hkName(r['hkUid'] as String? ?? ''),
          builder: (context, snap) => Text(
            '${r['familyName'] ?? '—'}  →  ${snap.data ?? r['hkUid'] ?? ''}',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800),
          ),
        ),
        const SizedBox(height: 2),
        Text(
            '${'★' * stars}${'☆' * (5 - stars)}'
            '${date != null ? '   ${formatDate(date)}' : ''}'
            '${r['editedAt'] != null ? ' · edited' : ''}',
            style: const TextStyle(fontSize: 12, color: Color(0xFFEF9F27))),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 12.5, height: 1.5)),
        ],
        if (reply != null && reply.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Reply: $reply',
              style: const TextStyle(fontSize: 12, color: AppTheme.grey600, height: 1.5)),
        ],
        if (removed) ...[
          const SizedBox(height: 6),
          Text('Removed: ${r['removedReason'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: AppTheme.red)),
        ] else
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _remove(r),
              icon: const Icon(Icons.block, size: 15),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            ),
          ),
      ]),
    );
  }
}
