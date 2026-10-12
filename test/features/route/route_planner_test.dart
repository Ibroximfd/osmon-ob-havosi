import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/geo_point.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/weather_condition.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/domain/route_models.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/domain/route_planner.dart';

final Place _tashkent = UzbekCities.tashkent;
final Place _samarkand = UzbekCities.regionalCentres[1];

RoutePath _path() => RoutePath(
  points: <GeoPoint>[_tashkent.point, _samarkand.point],
  distanceKm: 300,
  duration: const Duration(hours: 4),
  isEstimated: false,
);

PointForecast _forecast({bool fogUntilNoon = false}) => PointForecast(
  utcOffsetSeconds: 18000,
  hours: <PointHour>[
    for (var h = 0; h < 48; h++)
      PointHour(
        time: DateTime.utc(2026, 10, 11, h),
        temperature: 12,
        condition: fogUntilNoon && h < 12
            ? WeatherCondition.fog
            : WeatherCondition.clear,
        precipitationProbability: 0,
        visibility: fogUntilNoon && h < 12 ? 300 : 20000,
        windGusts: 20,
        snowfall: 0,
        isDay: h > 6 && h < 18,
      ),
  ],
);

void main() {
  test('checkpoints include both ends and stay within the road length', () {
    final samples = sampleCheckpoints(_path());
    expect(samples.first.distanceKm, 0);
    expect(samples.last.distanceKm, 300);
    expect(samples.length, greaterThanOrEqualTo(4));
    for (var i = 1; i < samples.length; i++) {
      expect(samples[i].distanceKm, greaterThan(samples[i - 1].distanceKm));
    }
  });

  test('ETAs follow the share of the distance travelled', () {
    final samples = sampleCheckpoints(_path());
    final plan = buildPlan(
      from: _tashkent,
      to: _samarkand,
      path: _path(),
      departure: DateTime.utc(2026, 10, 11, 14),
      originOffsetSeconds: 18000,
      samples: samples,
      forecasts: <PointForecast>[for (final _ in samples) _forecast()],
    );
    expect(plan.checkpoints.last.eta, DateTime.utc(2026, 10, 11, 18));
    expect(plan.hasHazards, isFalse);
  });

  test('morning fog suggests leaving later', () {
    final samples = sampleCheckpoints(_path());
    final plan = buildPlan(
      from: _tashkent,
      to: _samarkand,
      path: _path(),
      departure: DateTime.utc(2026, 10, 11, 8),
      originOffsetSeconds: 18000,
      samples: samples,
      forecasts: <PointForecast>[
        for (final _ in samples) _forecast(fogUntilNoon: true),
      ],
    );
    expect(plan.hasHazards, isTrue);
    expect(plan.checkpoints.first.hazards, contains(RouteHazard.fog));
    // Leaving at 08:00 the last stretch is past noon, but the first is not.
    expect(plan.betterDelay, isNull);
  });

  test('freezing rain is ice', () {
    final hazards = hazardsOf(
      PointHour(
        time: DateTime.utc(2026, 1, 5, 8),
        temperature: -1,
        condition: WeatherCondition.freezingRain,
        precipitationProbability: 80,
        visibility: 5000,
        windGusts: 10,
        snowfall: 0,
        isDay: true,
      ),
    );
    expect(hazards, contains(RouteHazard.ice));
  });
}
