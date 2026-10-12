import 'package:equatable/equatable.dart';

import '../../../core/domain/geo_point.dart';
import 'air_quality.dart';

enum AqiCategory {
  good,
  moderate,
  unhealthyForSensitive,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

/// US EPA breakpoints.
AqiCategory aqiCategoryOf(double aqi) {
  if (aqi <= 50) return AqiCategory.good;
  if (aqi <= 100) return AqiCategory.moderate;
  if (aqi <= 150) return AqiCategory.unhealthyForSensitive;
  if (aqi <= 200) return AqiCategory.unhealthy;
  if (aqi <= 300) return AqiCategory.veryUnhealthy;
  return AqiCategory.hazardous;
}

enum PollenLevel { none, low, moderate, high }

/// Thresholds (grains/m³) used by European pollen services: trees release
/// far more grains than grasses or weeds before people react.
PollenLevel pollenLevelOf(PollenType type, double grains) {
  final (low, high) = switch (type) {
    PollenType.alder || PollenType.birch || PollenType.olive => (10.0, 100.0),
    PollenType.grass => (5.0, 50.0),
    PollenType.mugwort || PollenType.ragweed => (5.0, 30.0),
  };
  if (grains < 1) return PollenLevel.none;
  if (grains < low) return PollenLevel.low;
  if (grains < high) return PollenLevel.moderate;
  return PollenLevel.high;
}

/// Plant groups that dominate allergy seasons in Central Asia.
enum SeasonalAllergen { trees, grasses, wormwood, goosefoot, ragweed }

final class SeasonalPollen extends Equatable {
  const SeasonalPollen(this.allergen, this.level);

  final SeasonalAllergen allergen;
  final PollenLevel level;

  @override
  List<Object?> get props => <Object?>[allergen, level];
}

/// Typical monthly intensity (index 0 = January) from Central Asian pollen
/// calendars. An estimate, labelled as such in the UI — used only where no
/// measured pollen exists.
const Map<SeasonalAllergen, List<int>> _calendar =
    <SeasonalAllergen, List<int>>{
      SeasonalAllergen.trees: <int>[0, 1, 2, 3, 2, 1, 0, 0, 0, 0, 0, 0],
      SeasonalAllergen.grasses: <int>[0, 0, 0, 2, 3, 3, 2, 1, 1, 0, 0, 0],
      SeasonalAllergen.wormwood: <int>[0, 0, 0, 0, 0, 0, 2, 3, 3, 1, 0, 0],
      SeasonalAllergen.goosefoot: <int>[0, 0, 0, 0, 0, 1, 2, 3, 3, 1, 0, 0],
      SeasonalAllergen.ragweed: <int>[0, 0, 0, 0, 0, 0, 0, 2, 3, 1, 0, 0],
    };

bool isInCentralAsia(GeoPoint point) =>
    point.latitude >= 35 &&
    point.latitude <= 56 &&
    point.longitude >= 46 &&
    point.longitude <= 88;

List<SeasonalPollen> seasonalPollenFor(int month) => <SeasonalPollen>[
  for (final entry in _calendar.entries)
    SeasonalPollen(entry.key, PollenLevel.values[entry.value[month - 1]]),
];

enum BreathingRisk { low, moderate, high }

/// Combines air pollution, dust and pollen into one answer for people with
/// asthma or allergies.
BreathingRisk breathingRiskOf({
  required AirReading air,
  required PollenLevel worstPollen,
}) {
  final aqi = air.usAqi ?? 0;
  final dust = air.dust ?? 0;
  if (aqi > 150 || dust >= 150 || worstPollen == PollenLevel.high) {
    return BreathingRisk.high;
  }
  if (aqi > 100 || dust >= 50 || worstPollen == PollenLevel.moderate) {
    return BreathingRisk.moderate;
  }
  return BreathingRisk.low;
}

enum HeatStress { none, caution, danger }

HeatStress heatStressOf(double apparentTemperature) {
  if (apparentTemperature >= 40) return HeatStress.danger;
  if (apparentTemperature >= 32) return HeatStress.caution;
  return HeatStress.none;
}
