import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../l10n/language_provider.dart';
import '../services/user_service.dart';
import 'shared_widgets.dart';
import 'hire_widgets.dart';
import '../models/housekeeper.dart';
import '../screens/family/review_flow_screen.dart';

// Reviews of one housekeeper, newest first, each with the housekeeper's reply.
// Nobody can delete a review. For 48 hours the family who wrote it can edit
// it, and the housekeeper (canReply) can edit their one reply.
class ReviewsSection extends StatefulWidget {
  final String hkUid;
  final String hkName;
  final bool canReply;
  // Tests pass reviews and the viewer; the app reads them from Firebase.
  final Stream<List<Map<String, dynamic>>>? reviews;
  final String? viewerUid;
  const ReviewsSection({
    super.key,
    required this.hkUid,
    required this.hkName,
    this.canReply = false,
    this.reviews,
    this.viewerUid,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  Stream<List<Map<String, dynamic>>>? _reviews;
  String? _viewerUid;

  @override
  void initState() {
    super.initState();
    try {
      _reviews = widget.reviews ?? UserService().watchHkReviews(widget.hkUid);
      _viewerUid = widget.viewerUid ?? FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      // Firebase not set up (widget tests): show no reviews.
      _reviews ??= Stream.value(const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final hkName = widget.hkName;
    final canReply = widget.canReply;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _reviews,
      builder: (context, snap) {
        final reviews = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel('${s.reviewsLabel} (${reviews.length})'),
            if (snap.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(s.noReviewsYet,
                    style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
              )
            else
              ...reviews.map((r) => _ReviewCard(
                    review: r,
                    hkName: hkName,
                    isMine: r['familyUid'] == _viewerUid,
                    canReply: canReply,
                  )),
          ],
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final String hkName;
  final bool isMine;
  final bool canReply;
  const _ReviewCard({
    required this.review,
    required this.hkName,
    required this.isMine,
    required this.canReply,
  });

  void _edit(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ReviewFlowScreen(
              hk: Housekeeper.basic(id: review['hkUid'] as String, name: hkName),
              existing: review)));

  // Reply, or edit the existing reply when [response] is given.
  Future<void> _reply(BuildContext context, Map<String, dynamic>? response) async {
    final s = LanguageProvider.strings(context);
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReplySheet(initialText: response?['text'] as String?),
    );
    if (text == null || text.trim().isEmpty) return;
    try {
      final id = review['id'] as String;
      if (response == null) {
        await UserService().respondToReview(id, text.trim());
      } else {
        await UserService()
            .editResponse(id, text.trim(), response['createdAt'] as Timestamp);
      }
    } catch (e) {
      debugPrint('Reply failed: $e');
      if (context.mounted) showErrorToast(context, s.errReplyNotSent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final now = DateTime.now();
    final stars = (review['starRating'] as num?)?.toInt() ?? 0;
    final name = (review['familyName'] as String?)?.trim() ?? '';
    final text = (review['reviewText'] as String?)?.trim() ?? '';
    final date = (review['createdAt'] as Timestamp?)?.toDate();
    final response = review['response'] as Map<String, dynamic>?;
    final responseText = (response?['text'] as String?) ?? '';

    final canEditReview =
        isMine && UserService.canEdit(review['createdAt'] as Timestamp?, now);
    final canEditReply = canReply &&
        response != null &&
        UserService.canEdit(response['createdAt'] as Timestamp?, now);

    Widget action(String label, IconData icon, VoidCallback onPressed) =>
        TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 15),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            textStyle: const TextStyle(fontSize: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: isMine ? AppTheme.primary : AppTheme.grey200,
            width: isMine ? 1 : 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(name.isEmpty ? '—' : name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
          ),
          if (date != null)
            Text(
                review['editedAt'] != null
                    ? '${formatDate(date)} · ${s.edited}'
                    : formatDate(date),
                style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          Text('★' * stars + '☆' * (5 - stars),
              style: const TextStyle(color: Color(0xFFEF9F27), fontSize: 14)),
          if (isMine) ...[
            const SizedBox(width: 8),
            Text(s.yourReviewTag,
                style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
          ],
        ]),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(fontSize: 12.5, color: AppTheme.grey800, height: 1.5)),
        ],
        if (responseText.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppTheme.grey100, borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  response!['editedAt'] != null
                      ? '${s.replyFrom(hkName.split(' ').first)} · ${s.edited}'
                      : s.replyFrom(hkName.split(' ').first),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.grey600)),
              const SizedBox(height: 3),
              Text(responseText,
                  style: const TextStyle(fontSize: 12, color: AppTheme.grey800, height: 1.5)),
            ]),
          ),
        if (canEditReview || canEditReply || (canReply && response == null))
          Align(
            alignment: Alignment.centerRight,
            child: canEditReview
                ? action(s.editReview, Icons.edit_outlined, () => _edit(context))
                : canEditReply
                    ? action(s.editReply, Icons.edit_outlined,
                        () => _reply(context, response))
                    : action(s.replyBtn, Icons.reply, () => _reply(context, null)),
          ),
      ]),
    );
  }
}

// Bottom sheet for the housekeeper's reply. Pops with the text.
class _ReplySheet extends StatefulWidget {
  final String? initialText;
  const _ReplySheet({this.initialText});

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final hasText = _controller.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.replyTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(s.replyHint,
                style: const TextStyle(fontSize: 12, color: AppTheme.grey600, height: 1.5)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: UserService.responseMaxLength,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: s.sendReply,
              onPressed: hasText ? () => Navigator.pop(context, _controller.text) : null,
            ),
          ],
        ),
      ),
    );
  }
}
