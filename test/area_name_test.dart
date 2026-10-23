import 'package:flutter_test/flutter_test.dart';
import 'package:homehelp/l10n/app_strings.dart';

void main() {
  final en = AppStrings('en');
  final am = AppStrings('am');

  test('Amharic area names show in English', () {
    expect(en.areaName('ቄርቆስ'), 'Kirkos');
    expect(en.areaName('ቦሌ'), 'Bole');
    expect(en.areaName('ንፋስ ስልክ ላፍቶ'), 'Nifas Silk-Lafto');
  });

  test('English area names show in Amharic', () {
    expect(am.areaName('Kirkos'), 'ቄርቆስ');
    expect(am.areaName('Lemi Kura'), 'ለሚ ኩራ');
  });

  test('names already in the current language are unchanged', () {
    expect(en.areaName('Kirkos'), 'Kirkos');
    expect(am.areaName('ቄርቆስ'), 'ቄርቆስ');
  });

  test('surrounding spaces are ignored', () {
    expect(en.areaName(' ቄርቆስ '), 'Kirkos');
  });

  test('unknown names are shown as stored', () {
    expect(en.areaName('Somewhere'), 'Somewhere');
    expect(am.areaName(''), '');
  });
}
