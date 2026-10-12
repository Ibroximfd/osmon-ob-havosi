import 'package:flutter/painting.dart';

import '../../../../core/theme/osmon_colors.dart';
import '../../../health/domain/health_assessment.dart';
import '../../../weather/presentation/widgets/daily_list.dart';

/// Colour scales shared by the map overlay and its legend.
abstract final class WeatherLayerColors {
  static Color temperature(double celsius) =>
      TemperatureRangeBar.colorFor(celsius);

  /// mm per hour.
  static Color precipitation(double rate) {
    if (rate >= 10) return OsmonColors.precipExtreme;
    if (rate >= 4) return OsmonColors.precipHeavy;
    if (rate >= 1) return OsmonColors.precipModerate;
    return OsmonColors.precipLight;
  }

  static Color airQuality(double aqi) => switch (aqiCategoryOf(aqi)) {
    AqiCategory.good => OsmonColors.good,
    AqiCategory.moderate => OsmonColors.moderate,
    AqiCategory.unhealthyForSensitive => OsmonColors.elevated,
    AqiCategory.unhealthy => OsmonColors.severe,
    AqiCategory.veryUnhealthy || AqiCategory.hazardous => OsmonColors.extreme,
  };
}
