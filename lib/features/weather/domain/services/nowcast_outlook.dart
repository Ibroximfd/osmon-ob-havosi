import 'package:equatable/equatable.dart';

import '../entities/forecast.dart';

/// What the next three hours of precipitation mean for someone about to go
/// out: "starts in 14 minutes, lasts 35", "stops in 20", or "dry".
sealed class NowcastOutlook extends Equatable {
  const NowcastOutlook();

  @override
  List<Object?> get props => const <Object?>[];
}

final class DryOutlook extends NowcastOutlook {
  const DryOutlook();
}

final class PrecipitationAhead extends NowcastOutlook {
  const PrecipitationAhead({
    required this.startsIn,
    required this.lasts,
    required this.intensity,
    required this.isSnow,
  });

  final Duration startsIn;

  /// Null when it is still falling at the end of the window.
  final Duration? lasts;
  final PrecipitationIntensity intensity;
  final bool isSnow;

  @override
  List<Object?> get props => <Object?>[startsIn, lasts, intensity, isSnow];
}

final class PrecipitationNow extends NowcastOutlook {
  const PrecipitationNow({
    required this.endsIn,
    required this.intensity,
    required this.isSnow,
  });

  /// Null when it does not stop inside the window.
  final Duration? endsIn;
  final PrecipitationIntensity intensity;
  final bool isSnow;

  @override
  List<Object?> get props => <Object?>[endsIn, intensity, isSnow];
}

enum PrecipitationIntensity { light, moderate, heavy }

/// mm per 15 minutes below which a step counts as dry (0.2 mm/h).
const double wetStepThreshold = 0.05;

PrecipitationIntensity intensityForRate(double millimetresPerHour) {
  if (millimetresPerHour >= 7.6) return PrecipitationIntensity.heavy;
  if (millimetresPerHour >= 2.5) return PrecipitationIntensity.moderate;
  return PrecipitationIntensity.light;
}

NowcastOutlook summarizeNowcast(
  List<NowcastStep> steps, {
  required DateTime now,
  required double temperature,
}) {
  const step = Duration(minutes: 15);
  final upcoming = steps
      .where((s) => !s.time.add(step).isBefore(now))
      .toList(growable: false);
  if (upcoming.isEmpty) return const DryOutlook();

  final isSnow = temperature <= 1;
  final firstWet = upcoming.indexWhere(
    (s) => s.precipitation >= wetStepThreshold,
  );
  if (firstWet == -1) return const DryOutlook();

  var lastWet = firstWet;
  while (lastWet + 1 < upcoming.length &&
      upcoming[lastWet + 1].precipitation >= wetStepThreshold) {
    lastWet++;
  }
  final peakRate = upcoming
      .sublist(firstWet, lastWet + 1)
      .map((s) => s.rate)
      .reduce((a, b) => a > b ? a : b);
  final intensity = intensityForRate(peakRate);
  final reachesWindowEnd = lastWet == upcoming.length - 1;
  final stopsAt = upcoming[lastWet].time.add(step);

  final startsAt = upcoming[firstWet].time;
  if (!startsAt.isAfter(now)) {
    return PrecipitationNow(
      endsIn: reachesWindowEnd ? null : stopsAt.difference(now),
      intensity: intensity,
      isSnow: isSnow,
    );
  }
  return PrecipitationAhead(
    startsIn: startsAt.difference(now),
    lasts: reachesWindowEnd ? null : stopsAt.difference(startsAt),
    intensity: intensity,
    isSnow: isSnow,
  );
}
