import '../../../../core/domain/place_time.dart';
import '../../../../core/sky/sky_scene.dart';
import '../../../../core/sky/sky_scene_resolver.dart';
import '../entities/forecast.dart';

/// The background scene for a forecast at [now] (place time).
SkyScene skySceneOf(Forecast forecast, DateTime now) {
  final today = forecast.daily
      .where((d) => d.date.isSameDayAs(now))
      .firstOrNull;
  int? minutesToSunEvent;
  if (today != null) {
    final toSunrise = today.sunrise.difference(now).inMinutes;
    final toSunset = today.sunset.difference(now).inMinutes;
    minutesToSunEvent = toSunrise.abs() < toSunset.abs() ? toSunrise : toSunset;
  }
  return resolveSkyScene(
    condition: forecast.current.condition,
    isDay: forecast.current.isDay,
    minutesToNearestSunEvent: minutesToSunEvent,
    dustConcentration: forecast.air?.dust,
    pm10: forecast.air?.pm10,
  );
}
