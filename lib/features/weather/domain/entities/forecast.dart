import 'package:equatable/equatable.dart';

import '../../../../core/domain/place.dart';
import '../../../../core/domain/weather_condition.dart';

/// Everything the home screen and its derivations need for one place. All
/// times are place wall-clock values (see `place_time.dart`).
final class Forecast extends Equatable {
  const Forecast({
    required this.place,
    required this.fetchedAt,
    required this.utcOffsetSeconds,
    required this.timezoneId,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.nowcast,
    required this.pressureHistory,
    this.air,
  });

  final Place place;

  /// Place wall-clock time the data was fetched.
  final DateTime fetchedAt;
  final int utcOffsetSeconds;
  final String timezoneId;
  final CurrentWeather current;

  /// From the current hour onward (up to ten days).
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  /// 15-minute precipitation for the next three hours.
  final List<NowcastStep> nowcast;

  /// Hourly sea-level pressure for the past 24 hours up to now.
  final List<PressureSample> pressureHistory;

  /// Null when the air-quality request failed; the rest still renders.
  final AirSnapshot? air;

  DailyWeather? get today => daily.isEmpty ? null : daily.first;

  @override
  List<Object?> get props => <Object?>[
    place,
    fetchedAt,
    utcOffsetSeconds,
    timezoneId,
    current,
    hourly,
    daily,
    nowcast,
    pressureHistory,
    air,
  ];
}

final class CurrentWeather extends Equatable {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.condition,
    required this.isDay,
    required this.humidity,
    required this.dewPoint,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.pressure,
    required this.cloudCover,
    required this.visibility,
    required this.uvIndex,
    required this.precipitation,
  });

  final DateTime time;

  /// °C
  final double temperature;
  final double apparentTemperature;
  final WeatherCondition condition;
  final bool isDay;

  /// %
  final double humidity;
  final double dewPoint;

  /// km/h
  final double windSpeed;

  /// Degrees the wind blows from, 0 = north.
  final double windDirection;
  final double windGusts;

  /// hPa, sea level.
  final double pressure;

  /// %
  final double cloudCover;

  /// Metres.
  final double visibility;
  final double uvIndex;

  /// mm in the last interval.
  final double precipitation;

  @override
  List<Object?> get props => <Object?>[
    time,
    temperature,
    apparentTemperature,
    condition,
    isDay,
    humidity,
    dewPoint,
    windSpeed,
    windDirection,
    windGusts,
    pressure,
    cloudCover,
    visibility,
    uvIndex,
    precipitation,
  ];
}

final class HourlyWeather extends Equatable {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.condition,
    required this.isDay,
    required this.precipitationProbability,
    required this.precipitation,
    required this.windSpeed,
    required this.windGusts,
    required this.uvIndex,
    required this.visibility,
    required this.cloudCover,
    required this.humidity,
  });

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final WeatherCondition condition;
  final bool isDay;

  /// 0–100
  final double precipitationProbability;
  final double precipitation;
  final double windSpeed;
  final double windGusts;
  final double uvIndex;
  final double visibility;
  final double cloudCover;
  final double humidity;

  @override
  List<Object?> get props => <Object?>[
    time,
    temperature,
    apparentTemperature,
    condition,
    isDay,
    precipitationProbability,
    precipitation,
    windSpeed,
    windGusts,
    uvIndex,
    visibility,
    cloudCover,
    humidity,
  ];
}

final class DailyWeather extends Equatable {
  const DailyWeather({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.condition,
    required this.precipitationProbability,
    required this.precipitationSum,
    required this.snowfallSum,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.windSpeedMax,
    required this.windGustsMax,
  });

  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final WeatherCondition condition;
  final double precipitationProbability;

  /// mm
  final double precipitationSum;

  /// cm
  final double snowfallSum;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final double windSpeedMax;
  final double windGustsMax;

  Duration get daylight => sunset.difference(sunrise);

  @override
  List<Object?> get props => <Object?>[
    date,
    minTemperature,
    maxTemperature,
    condition,
    precipitationProbability,
    precipitationSum,
    snowfallSum,
    sunrise,
    sunset,
    uvIndexMax,
    windSpeedMax,
    windGustsMax,
  ];
}

final class NowcastStep extends Equatable {
  const NowcastStep({required this.time, required this.precipitation});

  final DateTime time;

  /// mm during this 15-minute step.
  final double precipitation;

  /// mm per hour, the unit people compare intensities in.
  double get rate => precipitation * 4;

  @override
  List<Object?> get props => <Object?>[time, precipitation];
}

final class PressureSample extends Equatable {
  const PressureSample({required this.time, required this.pressure});

  final DateTime time;
  final double pressure;

  @override
  List<Object?> get props => <Object?>[time, pressure];
}

final class AirSnapshot extends Equatable {
  const AirSnapshot({
    required this.usAqi,
    required this.pm10,
    required this.pm25,
    required this.dust,
  });

  final double? usAqi;
  final double? pm10;
  final double? pm25;

  /// µg/m³ — drives the dust-storm sky.
  final double? dust;

  @override
  List<Object?> get props => <Object?>[usAqi, pm10, pm25, dust];
}

/// The same calendar day one year earlier, for "warmer than last year".
final class PastDay extends Equatable {
  const PastDay({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
  });

  final DateTime date;
  final double maxTemperature;
  final double minTemperature;

  @override
  List<Object?> get props => <Object?>[date, maxTemperature, minTemperature];
}
