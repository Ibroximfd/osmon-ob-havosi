import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/l10n/app_localizations.dart';

void main() {
  test('multi-value messages put each value in its own slot (uz)', () {
    final l10n = lookupAppLocalizations(const Locale('uz'));
    expect(
      l10n.irrigationDetail('11', '110', '3'),
      "3 kunda ~11 mm suv kerak (≈ 110 m³/ga) · kutilayotgan yog'in 3 mm",
    );
    expect(l10n.sprayWindow('Bugun', '06:00', '09:00'), 'Bugun, 06:00–09:00');
    expect(
      l10n.notifDailyBody('9°', '21°', '80%'),
      "Bugun 9°…21°. Yog'in ehtimoli 80%.",
    );
    expect(
      l10n.radarPeak('15:30', '2.4'),
      'Eng kuchli payt 15:30 · 2.4 mm/soat',
    );
  });

  test('every language renders every value of a multi-value message', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      final irrigation = l10n.irrigationDetail('11', '110', '3');
      expect(
        irrigation,
        allOf(contains('11'), contains('110'), contains(' 3 ')),
        reason: locale.languageCode,
      );
      expect(
        l10n.storyWind('15:00', '60 km/h'),
        allOf(contains('15:00'), contains('60')),
        reason: locale.languageCode,
      );
      expect(
        l10n.relativeInMinutes(5),
        contains('5'),
        reason: locale.languageCode,
      );
    }
  });
}
