import 'package:equatable/equatable.dart';

enum Crop { wheat, cotton, grape, vegetables, orchard }

/// Agronomic thresholds per crop. Frost is the air temperature at which
/// the sensitive stage (buds, seedlings, blossom) is damaged.
final class CropProfile {
  const CropProfile({
    required this.frostDamage,
    required this.gddBase,
    required this.cropCoefficient,
    required this.dryMoisture,
  });

  final double frostDamage;

  /// Base temperature for growing degree days (°C).
  final double gddBase;

  /// FAO-56 mid-season Kc, scales reference evapotranspiration.
  final double cropCoefficient;

  /// Volumetric soil moisture (m³/m³) below which to irrigate.
  final double dryMoisture;

  static CropProfile of(Crop crop) => switch (crop) {
    Crop.wheat => const CropProfile(
      frostDamage: -3,
      gddBase: 0,
      cropCoefficient: 1.1,
      dryMoisture: 0.18,
    ),
    Crop.cotton => const CropProfile(
      frostDamage: 2,
      gddBase: 15.6,
      cropCoefficient: 1.15,
      dryMoisture: 0.2,
    ),
    Crop.grape => const CropProfile(
      frostDamage: -1,
      gddBase: 10,
      cropCoefficient: 0.8,
      dryMoisture: 0.16,
    ),
    Crop.vegetables => const CropProfile(
      frostDamage: 1,
      gddBase: 10,
      cropCoefficient: 1.05,
      dryMoisture: 0.22,
    ),
    Crop.orchard => const CropProfile(
      frostDamage: -2,
      gddBase: 7,
      cropCoefficient: 0.95,
      dryMoisture: 0.18,
    ),
  };
}

final class FieldHour extends Equatable {
  const FieldHour({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.windGusts,
    required this.precipitationProbability,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final double windSpeed;
  final double windGusts;
  final double precipitationProbability;
  final bool isDay;

  @override
  List<Object?> get props => <Object?>[
    time,
    temperature,
    windSpeed,
    windGusts,
    precipitationProbability,
    isDay,
  ];
}

final class FieldDay extends Equatable {
  const FieldDay({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.precipitationSum,
    required this.precipitationProbability,
    required this.evapotranspiration,
  });

  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final double precipitationSum;
  final double precipitationProbability;

  /// Reference evapotranspiration ET₀, mm/day.
  final double evapotranspiration;

  double get meanTemperature => (minTemperature + maxTemperature) / 2;

  @override
  List<Object?> get props => <Object?>[
    date,
    minTemperature,
    maxTemperature,
    precipitationSum,
    precipitationProbability,
    evapotranspiration,
  ];
}

final class FieldConditions extends Equatable {
  const FieldConditions({
    required this.now,
    required this.soilTemperatureSurface,
    required this.soilTemperatureRoot,
    required this.soilMoisture,
    required this.hours,
    required this.days,
    required this.season,
  });

  final DateTime now;

  /// °C at 0 cm and 6 cm.
  final double soilTemperatureSurface;
  final double soilTemperatureRoot;

  /// m³/m³ at 1–3 cm.
  final double soilMoisture;

  /// Next 72 hours.
  final List<FieldHour> hours;

  /// Today and the next six days.
  final List<FieldDay> days;

  /// Daily temperatures since 1 March (empty before the season starts),
  /// for growing degree days.
  final List<FieldDay> season;

  @override
  List<Object?> get props => <Object?>[
    now,
    soilTemperatureSurface,
    soilTemperatureRoot,
    soilMoisture,
    hours,
    days,
    season,
  ];
}
