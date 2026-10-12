import 'package:adhan/adhan.dart' as adhan;

import '../../../core/domain/geo_point.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/prayer_day.dart';
import '../domain/prayer_times_source.dart';

/// Prayer times through the `adhan` library. The default method reproduces
/// the Muslim Board of Uzbekistan tables (fajr 15.5°, isha 15°, Hanafi
/// asr, maghrib three minutes after sunset) — verified against the
/// published Tashkent timetable in `prayer_times_test.dart`.
final class AdhanPrayerTimesSource implements PrayerTimesSource {
  const AdhanPrayerTimesSource();

  @override
  PrayerDay timesFor({
    required GeoPoint point,
    required DateTime date,
    required int utcOffsetSeconds,
    required PrayerMethod method,
  }) {
    final times = adhan.PrayerTimes.utcOffset(
      adhan.Coordinates(point.latitude, point.longitude),
      adhan.DateComponents(date.year, date.month, date.day),
      _parameters(method),
      Duration(seconds: utcOffsetSeconds),
    );
    // adhan returns UTC instants shifted by the offset; re-stamp them as
    // place wall-clock values like the rest of the app.
    DateTime wall(DateTime value) => DateTime.utc(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    return PrayerDay(
      date: DateTime.utc(date.year, date.month, date.day),
      times: <Prayer, DateTime>{
        Prayer.fajr: wall(times.fajr),
        Prayer.sunrise: wall(times.sunrise),
        Prayer.dhuhr: wall(times.dhuhr),
        Prayer.asr: wall(times.asr),
        Prayer.maghrib: wall(times.maghrib),
        Prayer.isha: wall(times.isha),
      },
    );
  }

  static adhan.CalculationParameters _parameters(PrayerMethod method) {
    final parameters = switch (method) {
      PrayerMethod.uzbekistan =>
        adhan.CalculationMethod.other.getParameters()
          ..fajrAngle = 15.5
          ..ishaAngle = 15
          ..adjustments.maghrib = 3
          ..adjustments.isha = 1,
      PrayerMethod.muslimWorldLeague =>
        adhan.CalculationMethod.muslim_world_league.getParameters(),
      PrayerMethod.karachi => adhan.CalculationMethod.karachi.getParameters(),
      PrayerMethod.ummAlQura =>
        adhan.CalculationMethod.umm_al_qura.getParameters(),
      PrayerMethod.isna =>
        adhan.CalculationMethod.north_america.getParameters(),
    };
    return parameters
      ..madhab = adhan.Madhab.hanafi
      ..highLatitudeRule = adhan.HighLatitudeRule.seventh_of_the_night;
  }
}
