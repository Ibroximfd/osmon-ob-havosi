import 'package:osmon_uzbekiston_ob_havosi/core/bloc/load_status.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/geo_point.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/weather_condition.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/domain/weather_alert.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/presentation/bloc/alerts_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/domain/field_conditions.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/presentation/bloc/field_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/domain/air_quality.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/presentation/bloc/health_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/domain/route_models.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/presentation/bloc/route_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/bloc/weather_bloc.dart';

/// City names as each language's users would see them from the geocoder.
const Map<String, Map<String, String>> _names = <String, Map<String, String>>{
  'uz': <String, String>{
    'tashkent': 'Toshkent',
    'samarkand': 'Samarqand',
    'jizzakh': 'Jizzax',
    'gulistan': 'Guliston',
    'nukus': 'Nukus',
    'fergana': "Farg'ona",
    'chilonzor': 'Chilonzor',
  },
  'ru': <String, String>{
    'tashkent': 'Ташкент',
    'samarkand': 'Самарканд',
    'jizzakh': 'Джизак',
    'gulistan': 'Гулистан',
    'nukus': 'Нукус',
    'fergana': 'Фергана',
    'chilonzor': 'Чиланзар',
  },
  'en': <String, String>{
    'tashkent': 'Tashkent',
    'samarkand': 'Samarkand',
    'jizzakh': 'Jizzakh',
    'gulistan': 'Gulistan',
    'nukus': 'Nukus',
    'fergana': 'Fergana',
    'chilonzor': 'Chilanzar',
  },
  'kk': <String, String>{
    'tashkent': 'Ташкент',
    'samarkand': 'Самарқанд',
    'jizzakh': 'Жизақ',
    'gulistan': 'Гүлстан',
    'nukus': 'Нөкіс',
    'fergana': 'Ферғана',
    'chilonzor': 'Шыланзар',
  },
  'ky': <String, String>{
    'tashkent': 'Ташкент',
    'samarkand': 'Самарканд',
    'jizzakh': 'Жизак',
    'gulistan': 'Гулистан',
    'nukus': 'Нукус',
    'fergana': 'Фергана',
    'chilonzor': 'Чиланзар',
  },
};

final class StoreSeeds {
  StoreSeeds(this.language);

  final String language;

  String name(String key) => _names[language]![key]!;

  Place get tashkent => Place(
    name: name('tashkent'),
    point: UzbekCities.tashkent.point,
    region: name('chilonzor'),
    countryCode: 'UZ',
    timezoneId: 'Asia/Tashkent',
  );

  Place get samarkand => Place(
    name: name('samarkand'),
    point: UzbekCities.regionalCentres[1].point,
    countryCode: 'UZ',
    timezoneId: 'Asia/Samarkand',
  );

  static final DateTime now = DateTime.utc(2026, 10, 12, 14, 1);
  static final DateTime today = DateTime.utc(2026, 10, 12);

  WeatherState home() {
    final hours = <HourlyWeather>[
      for (var i = 0; i < 48; i++)
        HourlyWeather(
          time: DateTime.utc(2026, 10, 12, 14).add(Duration(hours: i)),
          temperature: <double>[
            18,
            17,
            16,
            15,
            14,
            13,
            12,
            12,
            11,
            11,
            10,
            10,
            9,
            9,
            9,
            10,
            12,
            14,
            16,
            18,
            20,
            21,
            21,
            20,
          ][i % 24],
          apparentTemperature: 16,
          condition: i < 3
              ? WeatherCondition.rain
              : (i < 8
                    ? WeatherCondition.partlyCloudy
                    : WeatherCondition.clear),
          isDay: (i + 14) % 24 >= 7 && (i + 14) % 24 < 18,
          precipitationProbability: <double>[45, 80, 65, 30, 10][i < 5 ? i : 4],
          precipitation: 0,
          windSpeed: 12,
          windGusts: 24,
          uvIndex: 2,
          visibility: 18000,
          cloudCover: 60,
          humidity: 62,
        ),
    ];
    final conditions = <WeatherCondition>[
      WeatherCondition.rain,
      WeatherCondition.partlyCloudy,
      WeatherCondition.clear,
      WeatherCondition.clear,
      WeatherCondition.mainlyClear,
      WeatherCondition.overcast,
      WeatherCondition.rainShowers,
      WeatherCondition.partlyCloudy,
      WeatherCondition.clear,
      WeatherCondition.clear,
    ];
    final days = <DailyWeather>[
      for (var i = 0; i < 10; i++)
        DailyWeather(
          date: today.add(Duration(days: i)),
          minTemperature: <double>[9, 8, 10, 11, 12, 10, 8, 7, 9, 10][i],
          maxTemperature: <double>[21, 20, 23, 24, 25, 19, 16, 18, 21, 22][i],
          condition: conditions[i],
          precipitationProbability: <double>[
            80,
            20,
            0,
            0,
            5,
            30,
            70,
            20,
            0,
            0,
          ][i],
          precipitationSum: <double>[6, 0, 0, 0, 0, 1, 8, 0, 0, 0][i],
          snowfallSum: 0,
          sunrise: today.add(Duration(days: i, hours: 6, minutes: 32 + i)),
          sunset: today.add(Duration(days: i, hours: 17, minutes: 50 - i)),
          uvIndexMax: 4,
          windSpeedMax: 18,
          windGustsMax: 32,
        ),
    ];
    final forecast = Forecast(
      place: tashkent,
      fetchedAt: now,
      utcOffsetSeconds: 18000,
      timezoneId: 'Asia/Tashkent',
      current: CurrentWeather(
        time: now,
        temperature: 18,
        apparentTemperature: 16,
        condition: WeatherCondition.overcast,
        isDay: true,
        humidity: 62,
        dewPoint: 10,
        windSpeed: 12,
        windDirection: 300,
        windGusts: 24,
        pressure: 1009,
        cloudCover: 85,
        visibility: 14000,
        uvIndex: 2,
        precipitation: 0,
      ),
      hourly: hours,
      daily: days,
      nowcast: <NowcastStep>[
        for (var i = 0; i < 12; i++)
          NowcastStep(
            time: DateTime.utc(2026, 10, 12, 14).add(Duration(minutes: 15 * i)),
            precipitation: <double>[
              0,
              0.25,
              0.5,
              0.65,
              0.45,
              0.3,
              0.15,
              0,
              0,
              0,
              0,
              0,
            ][i],
          ),
      ],
      pressureHistory: <PressureSample>[
        for (var i = 0; i <= 24; i++)
          PressureSample(
            time: now.subtract(Duration(hours: 24 - i)),
            pressure: 1018 - i * 0.38,
          ),
      ],
      air: const AirSnapshot(usAqi: 54, pm10: 38, pm25: 16, dust: 6),
    );
    return WeatherState(
      status: LoadStatus.ready,
      place: tashkent,
      forecast: forecast,
      pastDay: PastDay(
        date: DateTime.utc(2025, 10, 12),
        maxTemperature: 15,
        minTemperature: 6,
      ),
    );
  }

  HealthState health() => HealthState(
    status: LoadStatus.ready,
    place: tashkent,
    report: AirQualityReport(
      current: AirReading(
        time: now,
        usAqi: 58,
        pm25: 17,
        pm10: 41,
        nitrogenDioxide: 12,
        ozone: 61,
        dust: 8,
      ),
      hourly: const <AirReading>[],
    ),
  );

  FieldState field() {
    final start = DateTime.utc(2026, 10, 12, 8);
    return FieldState(
      status: LoadStatus.ready,
      crop: Crop.wheat,
      place: tashkent,
      conditions: FieldConditions(
        now: start,
        soilTemperatureSurface: 11,
        soilTemperatureRoot: 9,
        soilMoisture: 0.15,
        hours: <FieldHour>[
          for (var i = 0; i < 72; i++)
            FieldHour(
              time: start.add(Duration(hours: i)),
              temperature: 14,
              windSpeed: (i % 24) < 4 ? 5 : 16,
              windGusts: (i % 24) < 4 ? 9 : 26,
              precipitationProbability: 5,
              isDay: (i % 24) < 10,
            ),
        ],
        days: <FieldDay>[
          for (var i = 0; i < 7; i++)
            FieldDay(
              date: today.add(Duration(days: i)),
              minTemperature: <double>[6, 1, -1, 3, 5, 4, 2][i],
              maxTemperature: <double>[18, 15, 13, 16, 19, 18, 15][i],
              precipitationSum: <double>[0, 0, 0, 0, 0, 3, 9][i],
              precipitationProbability: <double>[5, 0, 0, 10, 20, 55, 75][i],
              evapotranspiration: 3.4,
            ),
        ],
        season: <FieldDay>[
          for (var i = 0; i < 225; i++)
            FieldDay(
              date: DateTime.utc(2026, 3, 1).add(Duration(days: i)),
              minTemperature: 8 + (i < 140 ? i / 10 : 22 - (i - 140) / 8),
              maxTemperature: 18 + (i < 140 ? i / 9 : 22 - (i - 140) / 7),
              precipitationSum: 0,
              precipitationProbability: 0,
              evapotranspiration: 0,
            ),
        ],
      ),
    );
  }

  RouteState route() {
    PointHour hour(
      DateTime time,
      double temperature,
      WeatherCondition condition, {
      double visibility = 20000,
    }) => PointHour(
      time: time,
      temperature: temperature,
      condition: condition,
      precipitationProbability: condition.isWet ? 70 : 5,
      visibility: visibility,
      windGusts: 20,
      snowfall: 0,
      isDay: true,
    );
    RouteCheckpoint checkpoint(
      double km,
      int minutes,
      String? label,
      PointHour weather,
      Set<RouteHazard> hazards,
    ) => RouteCheckpoint(
      point: GeoPoint(41 - km / 300, 69 - km / 120),
      distanceKm: km,
      eta: DateTime.utc(2026, 10, 12, 15).add(Duration(minutes: minutes)),
      weather: weather,
      hazards: hazards,
      name: label,
    );
    final departure = DateTime.utc(2026, 10, 12, 15);
    return RouteState(
      status: LoadStatus.ready,
      from: tashkent,
      to: samarkand,
      plan: RoutePlan(
        from: tashkent,
        to: samarkand,
        path: RoutePath(
          points: <GeoPoint>[tashkent.point, samarkand.point],
          distanceKm: 308,
          duration: const Duration(hours: 3, minutes: 50),
          isEstimated: false,
        ),
        departure: departure,
        betterDelay: const Duration(hours: 1),
        checkpoints: <RouteCheckpoint>[
          checkpoint(
            0,
            0,
            null,
            hour(departure, 18, WeatherCondition.overcast),
            const <RouteHazard>{},
          ),
          checkpoint(
            105,
            70,
            name('gulistan'),
            hour(departure, 15, WeatherCondition.rain),
            const <RouteHazard>{},
          ),
          checkpoint(
            190,
            125,
            name('jizzakh'),
            hour(departure, 9, WeatherCondition.fog, visibility: 300),
            const <RouteHazard>{RouteHazard.fog},
          ),
          checkpoint(
            308,
            230,
            null,
            hour(departure, 14, WeatherCondition.clear),
            const <RouteHazard>{},
          ),
        ],
      ),
    );
  }

  AlertsState alerts() {
    Place region(String key, int index) => Place(
      name: name(key),
      point: UzbekCities.regionalCentres[index].point,
      countryCode: 'UZ',
    );
    final tomorrow = today.add(const Duration(days: 1));
    final list = <WeatherAlert>[
      WeatherAlert(
        place: region('nukus', 12),
        kind: AlertKind.dust,
        level: AlertLevel.orange,
        day: today,
        value: 420,
      ),
      WeatherAlert(
        place: region('fergana', 5),
        kind: AlertKind.thunderstorm,
        level: AlertLevel.orange,
        day: tomorrow,
        value: 14,
      ),
      WeatherAlert(
        place: tashkent,
        kind: AlertKind.heavyRain,
        level: AlertLevel.yellow,
        day: today,
        value: 18,
      ),
      WeatherAlert(
        place: region('jizzakh', 9),
        kind: AlertKind.wind,
        level: AlertLevel.yellow,
        day: tomorrow,
        value: 62,
      ),
    ];
    return AlertsState(
      status: LoadStatus.ready,
      alerts: list,
      ownPlace: tashkent,
    );
  }
}
