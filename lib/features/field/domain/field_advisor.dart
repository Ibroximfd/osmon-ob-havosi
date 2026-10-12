import 'package:equatable/equatable.dart';

import 'field_conditions.dart';

enum FrostRisk { none, possible, likely }

final class FrostOutlook extends Equatable {
  const FrostOutlook({
    required this.risk,
    required this.coldest,
    required this.night,
  });

  final FrostRisk risk;

  /// Lowest forecast air temperature of the next three nights (°C).
  final double coldest;

  /// Date of that night.
  final DateTime night;

  @override
  List<Object?> get props => <Object?>[risk, coldest, night];
}

/// Margin above the damage threshold at which frost is "possible": ground
/// frost forms a couple of degrees below the 2 m air temperature.
const double _frostMargin = 2;

FrostOutlook? frostOutlookFor(FieldConditions conditions, Crop crop) {
  final nights = conditions.days.take(3).toList();
  if (nights.isEmpty) return null;
  final coldest = nights.reduce(
    (a, b) => a.minTemperature <= b.minTemperature ? a : b,
  );
  final threshold = CropProfile.of(crop).frostDamage;
  final risk = coldest.minTemperature <= threshold
      ? FrostRisk.likely
      : coldest.minTemperature <= threshold + _frostMargin
      ? FrostRisk.possible
      : FrostRisk.none;
  return FrostOutlook(
    risk: risk,
    coldest: coldest.minTemperature,
    night: coldest.date,
  );
}

enum IrrigationNeed { notNeeded, soon, now }

final class IrrigationAdvice extends Equatable {
  const IrrigationAdvice({
    required this.need,
    required this.deficitMillimetres,
    required this.rainExpectedMillimetres,
  });

  final IrrigationNeed need;

  /// Crop water use over the next three days minus expected rain.
  final double deficitMillimetres;
  final double rainExpectedMillimetres;

  /// 1 mm over one hectare is 10 m³.
  double get cubicMetresPerHectare => deficitMillimetres * 10;

  @override
  List<Object?> get props => <Object?>[
    need,
    deficitMillimetres,
    rainExpectedMillimetres,
  ];
}

IrrigationAdvice irrigationAdviceFor(FieldConditions conditions, Crop crop) {
  final profile = CropProfile.of(crop);
  final next = conditions.days.take(3);
  final cropUse = next.fold<double>(
    0,
    (sum, d) => sum + d.evapotranspiration * profile.cropCoefficient,
  );
  final rain = next.fold<double>(0, (sum, d) => sum + d.precipitationSum);
  final deficit = (cropUse - rain).clamp(0, double.infinity).toDouble();
  final isDry = conditions.soilMoisture < profile.dryMoisture;
  final need = isDry && deficit > 5
      ? IrrigationNeed.now
      : (isDry || deficit > 10)
      ? IrrigationNeed.soon
      : IrrigationNeed.notNeeded;
  return IrrigationAdvice(
    need: need,
    deficitMillimetres: deficit,
    rainExpectedMillimetres: rain,
  );
}

final class SprayWindow extends Equatable {
  const SprayWindow(this.start, this.end);

  final DateTime start;

  /// Exclusive end hour.
  final DateTime end;

  Duration get length => end.difference(start);

  @override
  List<Object?> get props => <Object?>[start, end];
}

const double _sprayMaxWind = 12;
const double _sprayMaxGust = 20;
const double _sprayMaxRainChance = 20;
const double _sprayMinTemperature = 5;
const double _sprayMaxTemperature = 28;
const int _sprayMinHours = 2;

/// Daylight stretches of at least two hours that are calm, mild and stay
/// dry for the following three hours (so the product is not washed off).
List<SprayWindow> sprayWindowsFor(FieldConditions conditions) {
  final hours = conditions.hours;
  bool suitable(int i) {
    final h = hours[i];
    if (!h.isDay ||
        h.windSpeed > _sprayMaxWind ||
        h.windGusts > _sprayMaxGust ||
        h.temperature < _sprayMinTemperature ||
        h.temperature > _sprayMaxTemperature) {
      return false;
    }
    final dryAhead = hours
        .skip(i)
        .take(3)
        .every((next) => next.precipitationProbability < _sprayMaxRainChance);
    return dryAhead;
  }

  final windows = <SprayWindow>[];
  int? start;
  for (var i = 0; i <= hours.length; i++) {
    final ok = i < hours.length && suitable(i);
    if (ok) {
      start ??= i;
      continue;
    }
    if (start != null && i - start >= _sprayMinHours) {
      windows.add(
        SprayWindow(
          hours[start].time,
          hours[i - 1].time.add(const Duration(hours: 1)),
        ),
      );
    }
    start = null;
  }
  return windows;
}

/// The first of the next five days likely to be wet enough to stop field
/// work, or null.
FieldDay? wetDayAhead(FieldConditions conditions) => conditions.days
    .skip(1)
    .take(5)
    .where((d) => d.precipitationProbability >= 60)
    .firstOrNull;

/// Growing degree days since 1 March for [crop]; null before the season.
double? growingDegreeDays(FieldConditions conditions, Crop crop) {
  if (conditions.season.isEmpty) return null;
  final base = CropProfile.of(crop).gddBase;
  return conditions.season.fold<double>(
    0,
    (sum, d) => sum + (d.meanTemperature - base).clamp(0, double.infinity),
  );
}
