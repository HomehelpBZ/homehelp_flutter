import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homehelp/l10n/language_provider.dart';
import 'package:homehelp/models/housekeeper.dart';
import 'package:homehelp/screens/family/family_chat_screen.dart';
import 'package:homehelp/screens/family/hk_detail_screen.dart';
import 'package:homehelp/services/user_service.dart';
import 'package:homehelp/theme/app_theme.dart';
import 'package:homehelp/widgets/shared_widgets.dart';

class _PushRecorder extends NavigatorObserver {
  final routes = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      routes.add(route);
}

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  group('HkDetailScreen "Send message"', () {
    testWidgets('opens a chat with the housekeeper being viewed, not sample data',
        (tester) async {
      final recorder = _PushRecorder();
      await tester.pumpWidget(LanguageProvider(
        notifier: LanguageNotifier(),
        child: MaterialApp(
          navigatorObservers: [recorder],
          home: const HkDetailScreen(uid: 'real-hk-uid'),
        ),
      ));
      // No Firebase in tests: the profile load fails and the screen shows
      // with an empty profile, which is enough to reach the button.
      await tester.pumpAndSettle();

      final button = find.text('Send message');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      // The chat screen itself needs Firebase; only the route matters here.
      tester.takeException();

      final route = recorder.routes.last as MaterialPageRoute;
      final chat = route.builder(tester.element(find.byType(HkDetailScreen)))
          as FamilyChatScreen;
      expect(chat.hk.id, 'real-hk-uid');
      expect(chat.hk.id, isNot(sampleHousekeepers.first.id));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  group('Housekeeper.basic', () {
    test('keeps id, name and location', () {
      final hk = Housekeeper.basic(id: 'u1', name: 'Almaz Tesfaye', location: 'Bole');
      expect(hk.id, 'u1');
      expect(hk.name, 'Almaz Tesfaye');
      expect(hk.location, 'Bole');
    });

    test('builds initials from the first two words', () {
      expect(Housekeeper.basic(id: 'u', name: 'Almaz Tesfaye Kebede').initials,
          'AT');
      expect(Housekeeper.basic(id: 'u', name: 'almaz').initials, 'A');
      expect(Housekeeper.basic(id: 'u', name: '  ').initials, '?');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  group('chatThreadUpdate', () {
    Map<String, dynamic> update({
      required String sender,
      String? familyName,
      String? hkName,
    }) =>
        UserService.chatThreadUpdate(
          familyUid: 'fam',
          hkUid: 'hk',
          senderUid: sender,
          text: 'Selam',
          familyName: familyName,
          hkName: hkName,
        );

    test('stores both names so each side\'s message list can show them', () {
      final data = update(sender: 'fam', familyName: 'Abebe', hkName: 'Almaz');
      expect(data['familyName'], 'Abebe');
      expect(data['hkName'], 'Almaz');
    });

    test('leaves out unknown names so it never overwrites a saved one', () {
      final data = update(sender: 'hk', familyName: null, hkName: '');
      expect(data.containsKey('familyName'), isFalse);
      expect(data.containsKey('hkName'), isFalse);
    });

    test('family message: housekeeper gets an unread, family is reset', () {
      final data = update(sender: 'fam');
      expect(data[UserService.unreadHkField], isA<FieldValue>());
      expect(data[UserService.unreadFamilyField], 0);
    });

    test('housekeeper message: family gets an unread, housekeeper is reset', () {
      final data = update(sender: 'hk');
      expect(data[UserService.unreadFamilyField], isA<FieldValue>());
      expect(data[UserService.unreadHkField], 0);
    });

    test('records both participants and the last message', () {
      final data = update(sender: 'fam');
      expect(data['familyUid'], 'fam');
      expect(data['hkUid'], 'hk');
      expect(data['lastMessage'], 'Selam');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  group('sumUnread', () {
    test('adds up this side\'s unread count across all chats', () {
      final chats = [
        {UserService.unreadFamilyField: 2, UserService.unreadHkField: 5},
        {UserService.unreadFamilyField: 1},
        {UserService.unreadHkField: 3}, // no family count yet
      ];
      expect(UserService.sumUnread(chats, UserService.unreadFamilyField), 3);
      expect(UserService.sumUnread(chats, UserService.unreadHkField), 8);
    });

    test('is 0 with no chats, and ignores bad values', () {
      expect(UserService.sumUnread([], UserService.unreadHkField), 0);
      expect(
          UserService.sumUnread([
            {UserService.unreadHkField: -4},
            {UserService.unreadHkField: null},
          ], UserService.unreadHkField),
          0);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  group('UnreadBadgeIcon', () {
    Future<void> pump(WidgetTester tester, Stream<int>? count) =>
        tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: UnreadBadgeIcon(icon: Icons.message_outlined, count: count),
            ),
          ),
        ));

    // Let the stream event arrive, then rebuild.
    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump();
    }

    Badge badge(WidgetTester tester) => tester.widget(find.byType(Badge));

    testWidgets('shows a red count when there are unread messages',
        (tester) async {
      await pump(tester, Stream.value(3));
      await tester.pump();
      expect(badge(tester).isLabelVisible, isTrue);
      expect(find.text('3'), findsOneWidget);
      expect(badge(tester).backgroundColor, AppTheme.red);
    });

    testWidgets('hides the badge at 0', (tester) async {
      await pump(tester, Stream.value(0));
      await tester.pump();
      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('updates live as the count changes', (tester) async {
      final counts = StreamController<int>();
      await pump(tester, counts.stream);
      counts.add(1);
      await settle(tester);
      expect(find.text('1'), findsOneWidget);
      counts.add(2);
      await settle(tester);
      expect(find.text('2'), findsOneWidget);
      counts.add(0);
      await settle(tester);
      expect(badge(tester).isLabelVisible, isFalse);
      await counts.close();
    });

    testWidgets('guests (no stream) get the plain icon', (tester) async {
      await pump(tester, null);
      expect(find.byType(Badge), findsNothing);
      expect(find.byIcon(Icons.message_outlined), findsOneWidget);
    });

    test('caps the label at 99+', () {
      expect(UnreadBadgeIcon.label(7), '7');
      expect(UnreadBadgeIcon.label(99), '99');
      expect(UnreadBadgeIcon.label(150), '99+');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  group('sortNewestFirst', () {
    test('orders chats by last message, newest first; missing time goes last',
        () {
      Map<String, dynamic> chat(String id, int? seconds) => {
            'id': id,
            if (seconds != null) 'lastMessageAt': Timestamp(seconds, 0),
          };

      final sorted = UserService.sortNewestFirst(
          [chat('old', 100), chat('none', null), chat('new', 300), chat('mid', 200)]);

      expect(sorted.map((c) => c['id']), ['new', 'mid', 'old', 'none']);
    });
  });
}
