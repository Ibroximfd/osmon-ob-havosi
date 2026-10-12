import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/weather_condition.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/app_settings.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/services/day_story.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/services/life_indices.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/services/notification_triggers.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/services/pressure_trend.dart';

import '../../helpers/forecast_fixture.dart';

void main() {
  group('pressure trend', () {
    List<PressureSample> samples(List<double> values) => <PressureSample>[
      for (var i = 0; i < values.length; i++)
        PressureSample(
          time: fixtureNow.subtract(Duration(hours: values.length - 1 - i)),
          pressure: values[i],
        ),
    ];

    test('a 10 hPa fall over a day is high sensitivity', () {
      final trend = pressureTrendOf(
        samples(<double>[1020, 1016, 1013, 1012, 1010]),
      )!;
      expect(trend.direction, PressureDirection.falling);
      expect(trend.sensitivity, MeteoSensitivity.high);
    });

    test('a flat day is steady and low', () {
      final trend = pressureTrendOf(
        samples(<double>[1013, 1013.5, 1013, 1014]),
      )!;
      expect(trend.direction, PressureDirection.steady);
      expect(trend.sensitivity, MeteoSensitivity.low);
    });

    test('one sample gives no trend', () {
      expect(pressureTrendOf(samples(<double>[1013])), isNull);
    });
  });

  group('life indices', () {
    LifeIndex find(List<LifeIndex> all, LifeActivity activity) =>
        all.firstWhere((index) => index.activity == activity);

    test('a dry mild day is good for laundry and a car wash', () {
      final indices = lifeIndicesFor(buildForecast());
      expect(find(indices, LifeActivity.laundry).rating, IndexRating.good);
      expect(find(indices, LifeActivity.carWash).rating, IndexRating.good);
    });

    test('likely rain makes laundry poor', () {
      final forecast = buildForecast(
        hourly: <HourlyWeather>[
          for (var i = 0; i < 48; i++) hourAt(i, precipitationProbability: 70),
        ],
      );
      final laundry = find(lifeIndicesFor(forecast), LifeActivity.laundry);
      expect(laundry.rating, IndexRating.poor);
      expect(laundry.reason, IndexReason.rainExpected);
    });

    test('dust makes a car wash pointless', () {
      final forecast = buildForecast(
        air: const AirSnapshot(usAqi: 180, pm10: 300, pm25: 80, dust: 220),
      );
      expect(
        find(lifeIndicesFor(forecast), LifeActivity.carWash).reason,
        IndexReason.dusty,
      );
    });

    test('heat makes running poor', () {
      final running = find(
        lifeIndicesFor(buildForecast(temperature: 36)),
        LifeActivity.running,
      );
      expect(running.rating, IndexRating.poor);
      expect(running.reason, IndexReason.tooHot);
    });
  });

  group('day story', () {
    test('a calm day says so and suggests a best hour', () {
      final story = composeDayStory(
        buildForecast(minTemperature: 16, maxTemperature: 24),
      );
      expect(story.lines.single.topic, StoryTopic.calm);
      expect(story.bestHour, isNotNull);
    });

    test('a 14 degree swing between night and day suggests layers', () {
      final story = composeDayStory(buildForecast());
      expect(story.lines.single.topic, StoryTopic.layers);
    });

    test('a hot day leads with heat and caps at three lines', () {
      final story = composeDayStory(
        buildForecast(maxTemperature: 39, uvMax: 10, temperature: 35),
      );
      expect(story.lines.first.topic, StoryTopic.heat);
      expect(story.lines.length, lessThanOrEqualTo(3));
    });
  });

  group('notification triggers', () {
    test('rain within 45 minutes triggers once per hour key', () {
      final forecast = buildForecast(nowcast: nowcastOf(<double>[0, 0.2, 0.2]));
      final triggers = triggersFor(forecast);
      expect(triggers.map((t) => t.kind), contains(NotificationKind.rainSoon));
      expect(triggers.first.minutes, 15);
    });

    test('a storm in the next hours triggers a severe alert', () {
      final forecast = buildForecast(
        hourly: <HourlyWeather>[
          for (var i = 0; i < 24; i++)
            hourAt(
              i,
              condition: i == 3
                  ? WeatherCondition.thunderstorm
                  : WeatherCondition.clear,
            ),
        ],
      );
      expect(
        triggersFor(forecast).map((t) => t.kind),
        contains(NotificationKind.severeWeather),
      );
    });

    test('a sub-zero night in the evening triggers frost', () {
      final forecast = buildForecast(tomorrowMin: -3);
      // fixtureNow is 14:00, before the evening window.
      expect(
        triggersFor(forecast).map((t) => t.kind),
        isNot(contains(NotificationKind.frost)),
      );
    });
  });
}
