import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homehelp/services/user_service.dart';

void main() {
  group('reviewId', () {
    test('is familyUid_hkUid (firestore.rules relies on this)', () {
      expect(UserService.reviewId('fam1', 'hk1'), 'fam1_hk1');
    });
  });

  group('ratingAfterReview', () {
    test('first review sets the average to the stars', () {
      final r = UserService.ratingAfterReview(
          {'ratingAverage': 0.0, 'ratingCount': 0}, 4);
      expect(r, {'ratingAverage': 4.0, 'ratingCount': 1});
    });

    test('profile without rating fields counts as no reviews', () {
      final r = UserService.ratingAfterReview({'fullName': 'Betty'}, 5);
      expect(r, {'ratingAverage': 5.0, 'ratingCount': 1});
    });

    test('null profile counts as no reviews', () {
      expect(UserService.ratingAfterReview(null, 3)['ratingCount'], 1);
    });

    test('averages in the new rating', () {
      final r = UserService.ratingAfterReview(
          {'ratingAverage': 4.0, 'ratingCount': 2}, 5);
      expect(r['ratingCount'], 3);
      expect(r['ratingAverage'], closeTo(13 / 3, 1e-9));
    });

    test('accepts an int average (web stores 5.0 as 5)', () {
      final r =
          UserService.ratingAfterReview({'ratingAverage': 5, 'ratingCount': 1}, 4);
      expect(r, {'ratingAverage': 4.5, 'ratingCount': 2});
    });

    test('only writes the two rating fields', () {
      final r = UserService.ratingAfterReview(
          {'fullName': 'Betty', 'ratingAverage': 4.0, 'ratingCount': 1}, 2);
      expect(r.keys.toSet(), {'ratingAverage', 'ratingCount'});
    });
  });

  group('ratingText', () {
    test('0 when there are no reviews', () {
      expect(UserService.ratingText(null), '0');
      expect(UserService.ratingText({'ratingAverage': 0}), '0');
    });

    test('one decimal place', () {
      expect(UserService.ratingText({'ratingAverage': 13 / 3}), '4.3');
      expect(UserService.ratingText({'ratingAverage': 5}), '5.0');
    });
  });

  group('ratingAfterEdit', () {
    test('swaps the old stars for the new ones', () {
      final r = UserService.ratingAfterEdit(
          {'ratingAverage': 4.0, 'ratingCount': 2}, 5, 3);
      expect(r, {'ratingAverage': 3.0, 'ratingCount': 2});
    });

    test('count stays the same', () {
      final r = UserService.ratingAfterEdit(
          {'ratingAverage': 13 / 3, 'ratingCount': 3}, 4, 5);
      expect(r['ratingCount'], 3);
      expect(r['ratingAverage'], closeTo(14 / 3, 1e-9));
    });
  });

  group('canEdit (48 hours)', () {
    final written = DateTime(2026, 10, 1, 12);
    final ts = Timestamp.fromDate(written);

    test('allowed inside the window', () {
      expect(UserService.canEdit(ts, written.add(const Duration(hours: 47))), isTrue);
    });

    test('not allowed after 48 hours', () {
      expect(UserService.canEdit(ts, written.add(const Duration(hours: 48))), isFalse);
    });

    test('not allowed while the server time is still pending', () {
      expect(UserService.canEdit(null, written), isFalse);
    });
  });

  test('visibleReviews hides reviews an admin removed', () {
    final visible = UserService.visibleReviews([
      {'id': 'a'},
      {'id': 'b', 'removed': true},
      {'id': 'c', 'removed': false},
    ]);
    expect(visible.map((r) => r['id']), ['a', 'c']);
  });
}
