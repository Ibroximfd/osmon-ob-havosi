import '../../../core/domain/geo_point.dart';
import '../../settings/domain/app_settings.dart';
import 'prayer_day.dart';

/// Offline prayer-time calculation.
abstract interface class PrayerTimesSource {
  PrayerDay timesFor({
    required GeoPoint point,
    required DateTime date,
    required int utcOffsetSeconds,
    required PrayerMethod method,
  });
}
