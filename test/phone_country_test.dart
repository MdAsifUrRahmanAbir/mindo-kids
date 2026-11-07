import 'package:flutter_test/flutter_test.dart';

import 'package:mindo_kids/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/country/providers/country_providers.dart';

void main() {
  group('toInternationalPhone', () {
    test('drops the national leading 0', () {
      expect(toInternationalPhone('01712-345678', '+880'), '+8801712345678');
    });
    test('does not double a typed country code', () {
      expect(toInternationalPhone('8801712345678', '+880'), '+8801712345678');
      expect(toInternationalPhone('+8801712345678', '+880'), '+8801712345678');
    });
    test('works without a leading 0', () {
      expect(toInternationalPhone('98765 43210', '+91'), '+919876543210');
    });
    test('"Other" country keeps the typed international number', () {
      expect(toInternationalPhone('+44 7700 900123', ''), '+447700900123');
    });
  });

  group('validatePhone', () {
    test('accepts normal numbers', () {
      expect(validatePhone('01712345678', needsCountryCode: false), isNull);
    });
    test('rejects empty / too short / too long', () {
      expect(validatePhone('', needsCountryCode: false), isNotNull);
      expect(validatePhone('123', needsCountryCode: false), isNotNull);
      expect(validatePhone('1234567890123456', needsCountryCode: false), isNotNull);
    });
    test('requires + when the country has no dial code', () {
      expect(validatePhone('7700900123', needsCountryCode: true), isNotNull);
      expect(validatePhone('+447700900123', needsCountryCode: true), isNull);
    });
  });

  group('filterWorldsForCountry', () {
    const worlds = [
      WorldModel(id: 'english', title: 'English', order: 1),
      WorldModel(id: 'bangla', title: 'Bangla', order: 2),
      WorldModel(id: 'urdu', title: 'Urdu', order: 3),
    ];
    test('null = every world, original order', () {
      expect(filterWorldsForCountry(worlds, null).map((w) => w.id), ['english', 'bangla', 'urdu']);
    });
    test('keeps only listed worlds, in the country order', () {
      expect(filterWorldsForCountry(worlds, ['bangla', 'english']).map((w) => w.id), ['bangla', 'english']);
    });
  });
}
