import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/onboarding/domain/language_detection.dart';

void main() {
  test('GPS country wins over everything', () {
    expect(
      detectLanguage(
        gpsCountryCode: 'KZ',
        regionCountryCode: 'UZ',
        deviceLanguageCode: 'ru',
      ),
      'kk',
    );
  });

  test('each Central Asian country maps to its language', () {
    expect(detectLanguage(regionCountryCode: 'UZ'), 'uz');
    expect(detectLanguage(regionCountryCode: 'KG'), 'ky');
    expect(detectLanguage(regionCountryCode: 'TJ'), 'tg');
    expect(detectLanguage(regionCountryCode: 'RU'), 'ru');
  });

  test('elsewhere the phone language is used when supported', () {
    expect(
      detectLanguage(regionCountryCode: 'DE', deviceLanguageCode: 'ru'),
      'ru',
    );
    expect(
      detectLanguage(regionCountryCode: 'DE', deviceLanguageCode: 'de'),
      'en',
    );
  });

  test('nothing known falls back to Uzbek', () {
    expect(detectLanguage(), 'uz');
  });
}
