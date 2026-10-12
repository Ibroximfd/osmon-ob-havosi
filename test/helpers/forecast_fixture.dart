import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/weather_condition.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';

/// 11 Oct 2026, 14:00 in Tashkent (place wall-clock).
final DateTime fixtureNow = DateTime.utc(2026, 10, 11, 14);

HourlyWeather hourAt(
  int offsetHours, {
  double temperature = 22,
  double precipitationProbability = 0,
  WeatherCondition condition = WeatherCondition.clear,
  double windSpeed = 8,
  double windGusts = 15,
  double humidity = 40,
  double cloudCover = 10,
  double visibility = 20000,
  bool isDay = true,
}) => HourlyWeather(
  time: fixtureNow.add(Duration(hours: offsetHours)),
  temperature: temperature,
  apparentTemperature: temperature,
  condition: condition,
  isDay: isDay,
  precipitationProbability: precipitationProbability,
  precipitation: 0,
  windSpeed: windSpeed,
  windGusts: windGusts,
  uvIndex: 4,
  visibility: visibility,
  cloudCover: cloudCover,
  humidity: humidity,
);

Forecast buildForecast({
  double temperature = 22,
  WeatherCondition condition = WeatherCondition.clear,
  List<HourlyWeather>? hourly,
  List<NowcastStep> nowcast = const <NowcastStep>[],
  List<PressureSample> pressure = const <PressureSample>[],
  AirSnapshot? air,
  double minTemperature = 12,
  double maxTemperature = 26,
  double tomorrowMin = 10,
  double uvMax = 5,
}) {
  final today = DateTime.utc(2026, 10, 11);
  DailyWeather day(DateTime date, double min, double max) => DailyWeather(
    date: date,
    minTemperature: min,
    maxTemperature: max,
    condition: condition,
    precipitationProbability: 0,
    precipitationSum: 0,
    snowfallSum: 0,
    sunrise: date.add(const Duration(hours: 6, minutes: 31)),
    sunset: date.add(const Duration(hours: 17, minutes: 52)),
    uvIndexMax: uvMax,
    windSpeedMax: 15,
    windGustsMax: 25,
  );
  return Forecast(
    place: UzbekCities.tashkent,
    fetchedAt: fixtureNow,
    utcOffsetSeconds: 18000,
    timezoneId: 'Asia/Tashkent',
    current: CurrentWeather(
      time: fixtureNow,
      temperature: temperature,
      apparentTemperature: temperature,
      condition: condition,
      isDay: true,
      humidity: 40,
      dewPoint: 8,
      windSpeed: 8,
      windDirection: 315,
      windGusts: 15,
      pressure: 1013,
      cloudCover: 10,
      visibility: 20000,
      uvIndex: 4,
      precipitation: 0,
    ),
    hourly:
        hourly ??
        <HourlyWeather>[
          for (var i = 0; i < 48; i++) hourAt(i, temperature: temperature),
        ],
    daily: <DailyWeather>[
      day(today, minTemperature, maxTemperature),
      day(today.add(const Duration(days: 1)), tomorrowMin, maxTemperature),
      day(today.add(const Duration(days: 2)), tomorrowMin, maxTemperature),
    ],
    nowcast: nowcast,
    pressureHistory: pressure,
    air: air,
  );
}

List<NowcastStep> nowcastOf(List<double> amounts) => <NowcastStep>[
  for (var i = 0; i < amounts.length; i++)
    NowcastStep(
      time: fixtureNow.add(Duration(minutes: 15 * i)),
      precipitation: amounts[i],
    ),
];
