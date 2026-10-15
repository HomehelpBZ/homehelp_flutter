import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homehelp/l10n/app_strings.dart';
import 'package:homehelp/l10n/language_provider.dart';
import 'package:homehelp/widgets/hk_notifications.dart';

void main() {
  final s = AppStrings('en');
  final now = DateTime(2026, 10, 14, 12);
  Timestamp ago(Duration d) => Timestamp.fromDate(now.subtract(d));

  group('HkNotification.build', () {
    test('a chat with unread messages becomes a message notification', () {
      final items = HkNotification.build([
        {'familyUid': 'fam', 'familyName': 'Abebe', 'unreadHk': 2,
          'lastMessage': 'Are you free Monday?',
          'lastMessageAt': ago(const Duration(minutes: 5))},
      ], [], s);
      expect(items, hasLength(1));
      expect(items.first.text, 'Abebe sent you 2 new messages');
      expect(items.first.hint, 'Are you free Monday?');
      expect(items.first.familyUid, 'fam');
      expect(items.first.isUnread, isTrue);
      expect(items.first.isReview, isFalse);
    });

    test('chats with nothing unread are left out', () {
      expect(HkNotification.build([{'familyName': 'Abebe', 'unreadHk': 0}], [], s),
          isEmpty);
    });

    test('a review becomes a review notification, unread until replied', () {
      final items = HkNotification.build([], [
        {'familyName': 'Abebe', 'starRating': 5, 'createdAt': ago(const Duration(hours: 1))},
        {'familyName': 'Girma', 'starRating': 4, 'createdAt': ago(const Duration(days: 2)),
          'response': {'text': 'Thanks'}},
      ], s);
      expect(items.map((n) => n.text),
          ['Abebe left you a 5-star review', 'Girma left you a 4-star review']);
      expect(items.map((n) => n.isUnread), [true, false]);
      expect(items.every((n) => n.isReview), isTrue);
    });

    test('removed reviews are not shown', () {
      expect(HkNotification.build([], [
        {'familyName': 'Abebe', 'starRating': 1, 'removed': true},
      ], s), isEmpty);
    });

    test('newest first, messages and reviews mixed, capped at 6', () {
      final chats = [
        for (var i = 0; i < 4; i++)
          {'familyName': 'Chat$i', 'unreadHk': 1,
            'lastMessageAt': ago(Duration(hours: i * 2))},
      ];
      final reviews = [
        for (var i = 0; i < 4; i++)
          {'familyName': 'Review$i', 'starRating': 5,
            'createdAt': ago(Duration(hours: i * 2 + 1))},
      ];
      final items = HkNotification.build(chats, reviews, s);
      expect(items, hasLength(6));
      expect(items.first.text, startsWith('Chat0'));
      expect(items[1].text, startsWith('Review0'));
    });

    test('works in Amharic', () {
      final items = HkNotification.build([
        {'familyName': 'አበበ', 'unreadHk': 1},
      ], [], AppStrings('am'));
      expect(items.first.text, contains('አበበ'));
    });
  });

  test('timeAgo', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), s, now: now), 'Just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), s, now: now), '5 min ago');
    expect(timeAgo(now.subtract(const Duration(hours: 1)), s, now: now), '1 hour ago');
    expect(timeAgo(now.subtract(const Duration(days: 3)), s, now: now), '3 days ago');
  });

  group('HkNotificationsList', () {
    Future<List<HkNotification>> pump(WidgetTester tester,
        List<Map<String, dynamic>> chats, List<Map<String, dynamic>> reviews) async {
      final tapped = <HkNotification>[];
      await tester.pumpWidget(LanguageProvider(
        notifier: LanguageNotifier(),
        child: MaterialApp(
          home: Scaffold(
            body: HkNotificationsList(
              hkUid: 'hk',
              onTap: tapped.add,
              chats: Stream.value(chats),
              reviews: Stream.value(reviews),
            ),
          ),
        ),
      ));
      await tester.pump();
      return tapped;
    }

    testWidgets('shows "No notifications yet" when there is nothing new',
        (tester) async {
      await pump(tester, [], []);
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('tapping a message notification gives its chat', (tester) async {
      final tapped = await pump(tester, [
        {'familyUid': 'fam', 'familyName': 'Abebe', 'unreadHk': 1,
          'lastMessageAt': Timestamp.now()},
      ], [
        {'familyName': 'Girma', 'starRating': 5, 'createdAt': Timestamp.now()},
      ]);
      expect(find.text('Abebe sent you a message'), findsOneWidget);
      expect(find.text('Girma left you a 5-star review'), findsOneWidget);
      await tester.tap(find.text('Abebe sent you a message'));
      expect(tapped.single.familyUid, 'fam');
      expect(tapped.single.familyName, 'Abebe');
    });
  });
}
