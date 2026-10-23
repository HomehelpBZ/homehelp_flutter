import 'package:flutter_test/flutter_test.dart';
import 'package:homehelp/l10n/app_strings.dart';
import 'package:homehelp/screens/admin/admin_review_screen.dart';

void main() {
  test('every reason an admin can pick has an Amharic translation', () {
    final am = AppStrings('am');
    for (final reason in AdminReviewScreen.rejectionReasons) {
      expect(am.rejectionReason(reason), isNot(reason), reason: reason);
    }
  });

  test('reasons show as stored in English', () {
    final en = AppStrings('en');
    for (final reason in AdminReviewScreen.rejectionReasons) {
      expect(en.rejectionReason(reason), reason);
    }
  });

  test('an unknown reason is shown as stored', () {
    expect(AppStrings('am').rejectionReason('Something new'), 'Something new');
  });
}
