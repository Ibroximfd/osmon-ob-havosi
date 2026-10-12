import 'package:equatable/equatable.dart';

import '../entities/forecast.dart';

enum PressureDirection { falling, steady, rising }

/// How strongly weather-sensitive people are likely to feel the day.
enum MeteoSensitivity { low, moderate, high }

final class PressureTrend extends Equatable {
  const PressureTrend({
    required this.current,
    required this.change24h,
    required this.change3h,
  });

  final double current;
  final double change24h;
  final double change3h;

  static const double _steadyBand = 2;

  PressureDirection get direction {
    if (change24h <= -_steadyBand) return PressureDirection.falling;
    if (change24h >= _steadyBand) return PressureDirection.rising;
    return PressureDirection.steady;
  }

  /// Swings of ~10 hPa a day or 3 hPa in three hours are the ones linked to
  /// headaches and joint pain in the meteo-sensitivity literature.
  MeteoSensitivity get sensitivity {
    final day = change24h.abs();
    final recent = change3h.abs();
    if (day >= 10 || recent >= 3) return MeteoSensitivity.high;
    if (day >= 6 || recent >= 1.5) return MeteoSensitivity.moderate;
    return MeteoSensitivity.low;
  }

  @override
  List<Object?> get props => <Object?>[current, change24h, change3h];
}

/// Null when there are fewer than two samples to compare.
PressureTrend? pressureTrendOf(List<PressureSample> history) {
  if (history.length < 2) return null;
  final latest = history.last;
  final first = history.first;
  final threeHoursAgo = history.length > 3
      ? history[history.length - 4]
      : first;
  return PressureTrend(
    current: latest.pressure,
    change24h: latest.pressure - first.pressure,
    change3h: latest.pressure - threeHoursAgo.pressure,
  );
}
