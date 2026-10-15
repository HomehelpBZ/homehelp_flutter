import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homehelp/l10n/app_strings.dart';
import 'package:homehelp/l10n/language_provider.dart';
import 'package:homehelp/models/hire.dart';
import 'package:homehelp/models/housekeeper.dart';
import 'package:homehelp/screens/family/hire_form_screen.dart';
import 'package:homehelp/screens/housekeeper/hire_request_screen.dart';
import 'package:homehelp/services/hire_service.dart';
import 'package:homehelp/services/user_service.dart';
import 'package:homehelp/widgets/hire_widgets.dart';
import 'package:homehelp/widgets/reviews_section.dart';

Hire _hire({
  String status = Hire.accepted,
  DateTime? start,
}) =>
    Hire(
      familyUid: 'fam',
      hkUid: 'hk',
      startDate: start ?? DateTime(2026, 11, 1),
      monthlySalary: 5000,
      status: status,
    );

Widget _app(Widget home) => LanguageProvider(
      notifier: LanguageNotifier(),
      child: MaterialApp(home: home),
    );

void main() {
  group('Hire', () {
    final start = DateTime(2026, 11, 1);

    test('hire id matches the review id (firestore.rules relies on this)', () {
      expect(HireService.hireId('fam', 'hk'), UserService.reviewId('fam', 'hk'));
    });

    test('fromMap reads the stored fields', () {
      final h = Hire.fromMap({
        'familyUid': 'fam',
        'hkUid': 'hk',
        'familyName': 'Abebe',
        'hkName': 'Betty',
        'startDate': Timestamp.fromDate(start),
        'monthlySalary': 5000,
        'status': 'pending',
      });
      expect(h.startDate, start);
      expect(h.monthlySalary, 5000);
      expect(h.isPending, isTrue);
      expect(h.familyName, 'Abebe');
    });

    test('declined and cancelled hires are not open (family can ask again)', () {
      expect(_hire(status: Hire.pending).isOpen, isTrue);
      expect(_hire(status: Hire.accepted).isOpen, isTrue);
      expect(_hire(status: Hire.declined).isOpen, isFalse);
      expect(_hire(status: Hire.cancelled).isOpen, isFalse);
    });

    test('pending requests can always be cancelled', () {
      expect(_hire(status: Hire.pending, start: start)
          .canCancel(start.add(const Duration(days: 30))), isTrue);
    });

    test('accepted hires can be cancelled only before the start date', () {
      final h = _hire(start: start);
      expect(h.canCancel(start.subtract(const Duration(hours: 1))), isTrue);
      expect(h.canCancel(start), isFalse);
      expect(h.canCancel(start.add(const Duration(days: 1))), isFalse);
    });

    test('review opens 3 days after the start date', () {
      final h = _hire(start: start);
      expect(h.reviewOpensAt, start.add(const Duration(days: 3)));
      expect(h.canReview(start.add(const Duration(days: 2, hours: 23))), isFalse);
      expect(h.canReview(start.add(const Duration(days: 3))), isTrue);
    });

    test('only an accepted hire allows a review', () {
      final later = start.add(const Duration(days: 10));
      expect(_hire(status: Hire.pending, start: start).canReview(later), isFalse);
      expect(_hire(status: Hire.declined, start: start).canReview(later), isFalse);
      expect(_hire(status: Hire.cancelled, start: start).canReview(later), isFalse);
      expect(_hire(status: Hire.accepted, start: start).canReview(later), isTrue);
    });

    group('bothHaveMessaged', () {
      test('false until both sides have written', () {
        expect(Hire.bothHaveMessaged([], 'fam', 'hk'), isFalse);
        expect(Hire.bothHaveMessaged([{'senderUid': 'fam'}], 'fam', 'hk'), isFalse);
        expect(
            Hire.bothHaveMessaged(
                [{'senderUid': 'fam'}, {'senderUid': 'fam'}], 'fam', 'hk'),
            isFalse);
      });

      test('true once both have written', () {
        expect(
            Hire.bothHaveMessaged(
                [{'senderUid': 'hk'}, {'senderUid': 'fam'}], 'fam', 'hk'),
            isTrue);
      });

      test('hire notices do not count as a message', () {
        expect(
            Hire.bothHaveMessaged([
              {'senderUid': 'fam'},
              {'senderUid': 'hk', 'kind': HireService.noticeDeclined},
            ], 'fam', 'hk'),
            isFalse);
      });
    });
  });

  group('ratingAfterRemoval', () {
    test('takes the rating out of the average', () {
      final r = UserService.ratingAfterRemoval(
          {'ratingAverage': 13 / 3, 'ratingCount': 3}, 5);
      expect(r['ratingCount'], 2);
      expect(r['ratingAverage'], closeTo(4.0, 1e-9));
    });

    test('removing the last review resets to 0', () {
      expect(UserService.ratingAfterRemoval({'ratingAverage': 5, 'ratingCount': 1}, 5),
          {'ratingAverage': 0.0, 'ratingCount': 0});
    });

    test('add then remove gets back to the start', () {
      final start = {'ratingAverage': 4.2, 'ratingCount': 5};
      final added = UserService.ratingAfterReview(start, 1);
      final removed = UserService.ratingAfterRemoval(added, 1);
      expect(removed['ratingCount'], 5);
      expect(removed['ratingAverage'], closeTo(4.2, 1e-9));
    });
  });

  group('formatting', () {
    test('formatBirr adds thousands separators', () {
      expect(formatBirr(500), '500');
      expect(formatBirr(5000), '5,000');
      expect(formatBirr(1250000), '1,250,000');
    });

    test('formatDate is day/month/year', () {
      expect(formatDate(DateTime(2026, 11, 1)), '1/11/2026');
    });

    test('hire notices have a label in both languages', () {
      for (final am in [false, true]) {
        final s = AppStrings(am ? 'am' : 'en');
        for (final kind in [
          HireService.noticeRequested,
          HireService.noticeAccepted,
          HireService.noticeDeclined,
          HireService.noticeCancelled,
        ]) {
          expect(hireNoticeLabel(kind, s), isNotEmpty);
        }
        expect(hireNoticeLabel(null, s), isNull);
      }
    });
  });

  group('HireFormScreen', () {
    final hk = Housekeeper.basic(id: 'hk', name: 'Betty Alemu');

    testWidgets('asks for start date and monthly salary only', (tester) async {
      await tester.pumpWidget(_app(HireFormScreen(hk: hk)));
      expect(find.text('Hire Betty'), findsOneWidget);
      expect(find.text('START DATE'), findsOneWidget);
      expect(find.text('MONTHLY SALARY (BIRR)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('needs a start date before sending', (tester) async {
      await tester.pumpWidget(_app(HireFormScreen(hk: hk)));
      await tester.enterText(find.byType(TextField), '5000');
      await tester.tap(find.text('Send hire request'));
      await tester.pump();
      expect(find.text('Pick a start date'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('salary accepts digits only', (tester) async {
      await tester.pumpWidget(_app(HireFormScreen(hk: hk)));
      await tester.enterText(find.byType(TextField), '5,000 birr');
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '5000');
    });
  });

  group('HireRequestScreen', () {
    Future<void> pumpRequest(WidgetTester tester) => tester.pumpWidget(_app(
        HireRequestScreen(
            hire: _hire(status: Hire.pending, start: DateTime(2026, 11, 1)),
            familyName: 'Abebe family')));

    testWidgets('shows the start date and salary', (tester) async {
      await pumpRequest(tester);
      expect(find.text('Abebe family wants to hire you through HomeHelp.'),
          findsOneWidget);
      expect(find.text('1/11/2026'), findsOneWidget);
      expect(find.textContaining('5,000'), findsOneWidget);
    });

    testWidgets('accepting asks for confirmation first', (tester) async {
      await pumpRequest(tester);
      await tester.tap(find.text('Yes, I accept this job'));
      await tester.pumpAndSettle();
      expect(find.text('Accept this job?'), findsOneWidget);
      expect(find.text('Yes, accept'), findsOneWidget);
      // Going back saves nothing and leaves the request open.
      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Yes, I accept this job'), findsOneWidget);
    });

    testWidgets('declining asks for confirmation first', (tester) async {
      await pumpRequest(tester);
      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();
      expect(find.text('Decline this request?'), findsOneWidget);
    });
  });

  group('ReviewsSection', () {
    final review = {
      'id': 'fam_hk',
      'familyUid': 'fam',
      'hkUid': 'hk',
      'familyName': 'Abebe',
      'starRating': 4,
      'reviewText': 'Very reliable',
      'createdAt': Timestamp.now(),
    };

    Future<void> pumpReviews(WidgetTester tester, List<Map<String, dynamic>> reviews,
        {String? viewer, bool canReply = false}) async {
      await tester.pumpWidget(_app(Scaffold(
        body: ReviewsSection(
          hkUid: 'hk',
          hkName: 'Betty Alemu',
          canReply: canReply,
          reviews: Stream.value(reviews),
          viewerUid: viewer,
        ),
      )));
      await tester.pump();
    }

    testWidgets('shows "No reviews yet" when empty', (tester) async {
      await pumpReviews(tester, []);
      expect(find.text('No reviews yet'), findsOneWidget);
    });

    testWidgets('shows stars, text and the housekeeper reply', (tester) async {
      await pumpReviews(tester, [
        {...review, 'response': {'text': 'Thank you!'}},
      ]);
      expect(find.text('★★★★☆'), findsOneWidget);
      expect(find.text('Very reliable'), findsOneWidget);
      expect(find.text('Reply from Betty'), findsOneWidget);
      expect(find.text('Thank you!'), findsOneWidget);
    });

    testWidgets('guests and other families get no buttons', (tester) async {
      await pumpReviews(tester, [review], viewer: 'someone-else');
      expect(find.text('Edit review'), findsNothing);
      expect(find.text('Reply'), findsNothing);
    });

    testWidgets('nobody gets a delete button', (tester) async {
      await pumpReviews(tester, [review], viewer: 'fam');
      expect(find.textContaining('Delete'), findsNothing);
      await pumpReviews(tester, [review], viewer: 'hk', canReply: true);
      expect(find.textContaining('Delete'), findsNothing);
    });

    testWidgets('the family can edit their review within 48 hours',
        (tester) async {
      await pumpReviews(tester, [review], viewer: 'fam');
      expect(find.text('Your review'), findsOneWidget);
      expect(find.text('Edit review'), findsOneWidget);
    });

    testWidgets('no editing after 48 hours', (tester) async {
      await pumpReviews(tester, [
        {...review, 'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 49)))},
      ], viewer: 'fam');
      expect(find.text('Your review'), findsOneWidget);
      expect(find.text('Edit review'), findsNothing);
    });

    testWidgets('edited reviews and replies are marked', (tester) async {
      await pumpReviews(tester, [
        {...review, 'editedAt': Timestamp.now(),
          'response': {'text': 'Thanks', 'createdAt': Timestamp.now(),
            'editedAt': Timestamp.now()}},
      ]);
      expect(find.textContaining('edited'), findsNWidgets(2));
    });

    testWidgets('the housekeeper can edit their reply within 48 hours',
        (tester) async {
      await pumpReviews(tester, [
        {...review, 'response': {'text': 'Thanks', 'createdAt': Timestamp.now()}},
      ], viewer: 'hk', canReply: true);
      expect(find.text('Edit reply'), findsOneWidget);
      expect(find.text('Reply'), findsNothing);
      await tester.tap(find.text('Edit reply'));
      await tester.pumpAndSettle();
      // The sheet opens with the current reply.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Thanks');
    });

    testWidgets('no reply editing after 48 hours', (tester) async {
      await pumpReviews(tester, [
        {...review, 'response': {'text': 'Thanks', 'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 49)))}},
      ], viewer: 'hk', canReply: true);
      expect(find.text('Edit reply'), findsNothing);
      expect(find.text('Reply'), findsNothing);
    });

    testWidgets('the housekeeper can reply once', (tester) async {
      await pumpReviews(tester, [
        review,
        {...review, 'id': 'fam2_hk', 'familyUid': 'fam2',
          'response': {'text': 'Thanks'}},
      ], viewer: 'hk', canReply: true);
      // Only the review without a reply has the button.
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('the reply box is limited to 300 characters', (tester) async {
      await pumpReviews(tester, [review], viewer: 'hk', canReply: true);
      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();
      expect(find.text('Reply to this review'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'x' * 400);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLength, 300);
      expect(field.controller!.text.length, 300);
    });
  });
}
