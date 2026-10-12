import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/services/nowcast_outlook.dart';

import '../../helpers/forecast_fixture.dart';

void main() {
  group('summarizeNowcast', () {
    test('no wet step is dry', () {
      final outlook = summarizeNowcast(
        nowcastOf(<double>[0, 0, 0.01, 0]),
        now: fixtureNow,
        temperature: 20,
      );
      expect(outlook, const DryOutlook());
    });

    test('rain starting in 30 minutes for 45 minutes', () {
      final outlook = summarizeNowcast(
        nowcastOf(<double>[0, 0, 0.3, 0.7, 0.2, 0, 0, 0]),
        now: fixtureNow,
        temperature: 18,
      );
      expect(
        outlook,
        const PrecipitationAhead(
          startsIn: Duration(minutes: 30),
          lasts: Duration(minutes: 45),
          intensity: PrecipitationIntensity.moderate,
          isSnow: false,
        ),
      );
    });

    test('rain falling now that stops within the window', () {
      final outlook = summarizeNowcast(
        nowcastOf(<double>[0.1, 0.1, 0, 0]),
        now: fixtureNow.add(const Duration(minutes: 5)),
        temperature: 18,
      );
      expect(outlook, isA<PrecipitationNow>());
      expect((outlook as PrecipitationNow).endsIn, const Duration(minutes: 25));
    });

    test('precipitation at or below 1 °C is snow', () {
      final outlook = summarizeNowcast(
        nowcastOf(<double>[0, 0.2]),
        now: fixtureNow,
        temperature: 0.5,
      );
      expect((outlook as PrecipitationAhead).isSnow, isTrue);
    });

    test('rain still falling at the end of the window has no end', () {
      final outlook = summarizeNowcast(
        nowcastOf(<double>[0, 2.5, 2.5]),
        now: fixtureNow,
        temperature: 15,
      );
      final ahead = outlook as PrecipitationAhead;
      expect(ahead.lasts, isNull);
      expect(ahead.intensity, PrecipitationIntensity.heavy);
    });
  });
}
