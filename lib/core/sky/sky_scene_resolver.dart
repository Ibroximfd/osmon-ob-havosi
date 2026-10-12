import '../domain/weather_condition.dart';
import 'sky_scene.dart';

/// Dust concentration (µg/m³) from which the sky turns into a dust storm.
const double _dustStormThreshold = 150;

/// PM10 (µg/m³) that, with wind, reads as a dust event even when the dust
/// field itself is not reported.
const double _pm10DustThreshold = 250;

/// Minutes around sunrise/sunset that get the twilight palette.
const int _twilightWindowMinutes = 40;

/// Picks the background scene. Order matters: a storm outranks everything,
/// dust outranks plain cloud, and twilight only replaces a clear sky.
SkyScene resolveSkyScene({
  required WeatherCondition condition,
  required bool isDay,
  int? minutesToNearestSunEvent,
  double? dustConcentration,
  double? pm10,
}) {
  if (condition.isStormy) return SkyScene.storm;
  final isDusty =
      (dustConcentration ?? 0) >= _dustStormThreshold ||
      (pm10 ?? 0) >= _pm10DustThreshold;
  if (isDusty) return SkyScene.dust;
  if (condition.isSnowy) return SkyScene.snow;
  if (condition.isWet) return SkyScene.rain;
  if (condition == WeatherCondition.fog) return SkyScene.fog;
  if (condition == WeatherCondition.overcast ||
      condition == WeatherCondition.partlyCloudy) {
    return isDay ? SkyScene.cloudyDay : SkyScene.cloudyNight;
  }
  final nearSunEvent =
      minutesToNearestSunEvent != null &&
      minutesToNearestSunEvent.abs() <= _twilightWindowMinutes;
  if (nearSunEvent) return SkyScene.twilight;
  return isDay ? SkyScene.clearDay : SkyScene.clearNight;
}
