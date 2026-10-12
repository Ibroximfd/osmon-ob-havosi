import 'package:equatable/equatable.dart';

import '../../../core/domain/place.dart';
import '../../../core/domain/weather_condition.dart';

enum AlertKind { heavyRain, thunderstorm, hail, heat, frost, wind, snow, dust }

/// Colour-coded like national meteorological services.
enum AlertLevel { yellow, orange, red }

final class WeatherAlert extends Equatable {
  const WeatherAlert({
    required this.place,
    required this.kind,
    required this.level,
    required this.day,
    required this.value,
  });

  final Place place;
  final AlertKind kind;
  final AlertLevel level;

  /// Place-time date the alert applies to.
  final DateTime day;

  /// The measured quantity behind the alert (mm, °C, km/h, cm, µg/m³).
  final double value;

  @override
  List<Object?> get props => <Object?>[place, kind, level, day, value];
}

/// One day of a region's daily forecast — the alert rules' input.
final class RegionDay extends Equatable {
  const RegionDay({
    required this.date,
    required this.condition,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationSum,
    required this.snowfallSum,
    required this.windGustsMax,
    this.dustMax,
  });

  final DateTime date;
  final WeatherCondition condition;
  final double maxTemperature;
  final double minTemperature;
  final double precipitationSum;
  final double snowfallSum;
  final double windGustsMax;
  final double? dustMax;

  @override
  List<Object?> get props => <Object?>[
    date,
    condition,
    maxTemperature,
    minTemperature,
    precipitationSum,
    snowfallSum,
    windGustsMax,
    dustMax,
  ];
}

/// Thresholds tuned for Central Asia: 40 °C summers are normal, so heat
/// starts at 40; a 20 mm day is heavy rain in this climate.
List<WeatherAlert> alertsFor(Place place, RegionDay day) {
  WeatherAlert alert(AlertKind kind, AlertLevel level, double value) =>
      WeatherAlert(
        place: place,
        kind: kind,
        level: level,
        day: day.date,
        value: value,
      );

  AlertLevel? graded(double value, double yellow, double orange, double red) {
    if (value >= red) return AlertLevel.red;
    if (value >= orange) return AlertLevel.orange;
    if (value >= yellow) return AlertLevel.yellow;
    return null;
  }

  return <WeatherAlert>[
    if (day.condition == WeatherCondition.thunderstormHail)
      alert(AlertKind.hail, AlertLevel.red, day.precipitationSum)
    else if (day.condition.isStormy)
      alert(AlertKind.thunderstorm, AlertLevel.orange, day.precipitationSum),
    if (graded(day.precipitationSum, 15, 30, 50) case final level?)
      alert(AlertKind.heavyRain, level, day.precipitationSum),
    if (graded(day.snowfallSum, 3, 10, 20) case final level?)
      alert(AlertKind.snow, level, day.snowfallSum),
    if (graded(day.maxTemperature, 40, 43, 46) case final level?)
      alert(AlertKind.heat, level, day.maxTemperature),
    if (graded(-day.minTemperature, 10, 15, 20) case final level?)
      alert(AlertKind.frost, level, day.minTemperature),
    if (graded(day.windGustsMax, 54, 72, 90) case final level?)
      alert(AlertKind.wind, level, day.windGustsMax),
    if (graded(day.dustMax ?? 0, 150, 400, 800) case final level?)
      alert(AlertKind.dust, level, day.dustMax ?? 0),
  ];
}
