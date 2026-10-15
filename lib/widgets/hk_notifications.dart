import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import '../l10n/language_provider.dart';
import '../services/user_service.dart';

// One row in the housekeeper's home screen notifications.
class HkNotification {
  final String text;
  final String? hint;
  final DateTime? time;
  final bool isUnread;
  final String? familyUid; // set for message notifications
  final String? familyName;
  final bool isReview;

  const HkNotification({
    required this.text,
    this.hint,
    required this.time,
    required this.isUnread,
    this.familyUid,
    this.familyName,
    this.isReview = false,
  });

  // Built from live data: chats with unread messages, and reviews (unread
  // until the housekeeper replies). Newest first.
  static List<HkNotification> build(List<Map<String, dynamic>> chats,
      List<Map<String, dynamic>> reviews, AppStrings s,
      {int limit = 6}) {
    final items = <HkNotification>[];
    for (final c in chats) {
      final unread = (c[UserService.unreadHkField] as num?)?.toInt() ?? 0;
      if (unread <= 0) continue;
      final name = (c['familyName'] as String?)?.trim() ?? '';
      final display = name.isEmpty ? s.family : name;
      items.add(HkNotification(
        text: s.notifNewMessages(display, unread),
        hint: c['lastMessage'] as String?,
        time: (c['lastMessageAt'] as Timestamp?)?.toDate(),
        isUnread: true,
        familyUid: c['familyUid'] as String?,
        familyName: display,
      ));
    }
    for (final r in UserService.visibleReviews(reviews)) {
      final name = (r['familyName'] as String?)?.trim() ?? '';
      final replied = r['response'] != null;
      items.add(HkNotification(
        text: s.notifNewReview(name.isEmpty ? s.family : name,
            (r['starRating'] as num?)?.toInt() ?? 0),
        hint: replied ? null : s.notifReplyHint,
        time: (r['createdAt'] as Timestamp?)?.toDate(),
        isUnread: !replied,
        isReview: true,
      ));
    }
    items.sort((a, b) => (b.time ?? DateTime(0)).compareTo(a.time ?? DateTime(0)));
    return items.take(limit).toList();
  }
}

// "5 min ago", "2 hours ago", "3 days ago".
String timeAgo(DateTime? t, AppStrings s, {DateTime? now}) {
  if (t == null) return s.justNow;
  final d = (now ?? DateTime.now()).difference(t);
  if (d.inMinutes < 1) return s.justNow;
  if (d.inHours < 1) return s.minutesAgo(d.inMinutes);
  if (d.inDays < 1) return s.hoursAgo(d.inHours);
  return s.daysAgo(d.inDays);
}

// The Notifications list on the housekeeper's home screen. Tapping a message
// notification opens that chat; a review notification opens the profile.
class HkNotificationsList extends StatefulWidget {
  final String? hkUid;
  final void Function(HkNotification) onTap;
  // Tests pass data in; the app reads it from Firebase.
  final Stream<List<Map<String, dynamic>>>? chats;
  final Stream<List<Map<String, dynamic>>>? reviews;

  const HkNotificationsList({
    super.key,
    required this.hkUid,
    required this.onTap,
    this.chats,
    this.reviews,
  });

  @override
  State<HkNotificationsList> createState() => _HkNotificationsListState();
}

class _HkNotificationsListState extends State<HkNotificationsList> {
  final List<StreamSubscription> _subs = [];
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    Stream<List<Map<String, dynamic>>>? chats = widget.chats;
    Stream<List<Map<String, dynamic>>>? reviews = widget.reviews;
    final uid = widget.hkUid;
    if (uid != null && (chats == null || reviews == null)) {
      try {
        final svc = UserService();
        chats ??= svc.watchHkChats(uid);
        reviews ??= svc.watchHkReviews(uid);
      } catch (_) {
        // Firebase not set up (widget tests): no notifications.
      }
    }
    void onError(Object e) => debugPrint('Notifications failed: $e');
    if (chats != null) {
      _subs.add(chats.listen((c) => setState(() => _chats = c), onError: onError));
    }
    if (reviews != null) {
      _subs.add(
          reviews.listen((r) => setState(() => _reviews = r), onError: onError));
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final items = HkNotification.build(_chats, _reviews, s);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(s.noNotifications,
            style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
      );
    }
    return Column(
      children: items.map((n) => _NotificationRow(
            item: n,
            time: timeAgo(n.time, s),
            onTap: () => widget.onTap(n),
          )).toList(),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final HkNotification item;
  final String time;
  final VoidCallback onTap;
  const _NotificationRow({required this.item, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8, height: 8,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: item.isUnread ? AppTheme.red : AppTheme.grey200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Icon(item.isReview ? Icons.star_outline : Icons.message_outlined,
                size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.text,
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.grey800,
                          fontWeight: item.isUnread ? FontWeight.w500 : FontWeight.normal)),
                  if (item.hint != null && item.hint!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                  ],
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.grey400),
          ],
        ),
      ),
    );
  }
}
