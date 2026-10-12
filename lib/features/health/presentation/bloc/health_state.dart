part of 'health_bloc.dart';

final class HealthState extends Equatable {
  const HealthState({
    this.status = LoadStatus.initial,
    this.place,
    this.report,
    this.failure,
  });

  final LoadStatus status;
  final Place? place;
  final AirQualityReport? report;
  final DataFailure? failure;

  AqiCategory? get aqiCategory {
    final aqi = report?.current.usAqi;
    return aqi == null ? null : aqiCategoryOf(aqi);
  }

  /// Measured pollen, strongest first; empty outside the CAMS domain.
  List<MapEntry<PollenType, PollenLevel>> get measuredPollen {
    final pollen = report?.current.pollen ?? const <PollenType, double>{};
    final entries = <MapEntry<PollenType, PollenLevel>>[
      for (final entry in pollen.entries)
        MapEntry<PollenType, PollenLevel>(
          entry.key,
          pollenLevelOf(entry.key, entry.value),
        ),
    ]..sort((a, b) => b.value.index.compareTo(a.value.index));
    return entries;
  }

  /// The calendar estimate, offered only in Central Asia without data.
  List<SeasonalPollen> seasonalPollen(int month) {
    final data = report;
    final location = place;
    if (data == null || data.hasMeasuredPollen || location == null) {
      return const <SeasonalPollen>[];
    }
    if (!isInCentralAsia(location.point)) return const <SeasonalPollen>[];
    return seasonalPollenFor(month);
  }

  PollenLevel worstPollen(int month) {
    final measured = measuredPollen;
    if (measured.isNotEmpty) return measured.first.value;
    final seasonal = seasonalPollen(month);
    if (seasonal.isEmpty) return PollenLevel.none;
    return seasonal
        .map((s) => s.level)
        .reduce((a, b) => a.index >= b.index ? a : b);
  }

  BreathingRisk? breathingRisk(int month) {
    final data = report;
    if (data == null) return null;
    return breathingRiskOf(air: data.current, worstPollen: worstPollen(month));
  }

  @override
  List<Object?> get props => <Object?>[status, place, report, failure];
}
