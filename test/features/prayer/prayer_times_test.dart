import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/data/adhan_prayer_times_source.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/domain/astronomy.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/domain/prayer_day.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/app_settings.dart';

/// Published Tashkent timetable (namoz-vaqti.uz, Muslim Board of Uzbekistan
/// method), September 2026: fajr, sunrise, dhuhr, asr, maghrib, isha.
const Map<int, List<String>> _official = <int, List<String>>{
  1: <String>['04:27', '05:49', '12:23', '17:01', '19:00', '20:18'],
  15: <String>['04:43', '06:03', '12:18', '16:42', '18:36', '19:52'],
  30: <String>['05:00', '06:19', '12:13', '16:20', '18:11', '19:25'],
};

/// The board rounds to whole minutes and applies its own small offsets.
const int _toleranceMinutes = 2;

int _minutes(String hhmm) {
  final parts = hhmm.split(':').map(int.parse).toList();
  return parts[0] * 60 + parts[1];
}

void main() {
  const source = AdhanPrayerTimesSource();
  const tashkentOffset = 5 * 3600;

  group('Uzbekistan method matches the official Tashkent timetable', () {
    for (final entry in _official.entries) {
      test('September ${entry.key}', () {
        final day = source.timesFor(
          point: UzbekCities.tashkent.point,
          date: DateTime.utc(2026, 9, entry.key),
          utcOffsetSeconds: tashkentOffset,
          method: PrayerMethod.uzbekistan,
        );
        for (var i = 0; i < Prayer.values.length; i++) {
          final prayer = Prayer.values[i];
          final computed = day[prayer].hour * 60 + day[prayer].minute;
          expect(
            (computed - _minutes(entry.value[i])).abs(),
            lessThanOrEqualTo(_toleranceMinutes),
            reason: '$prayer: computed ${day[prayer]} vs ${entry.value[i]}',
          );
        }
      });
    }
  });

  group('astronomy', () {
    test('sunrise and sunset agree with the prayer calculation', () {
      final sun = sunDayFor(
        UzbekCities.tashkent.point,
        DateTime.utc(2026, 9, 1),
        tashkentOffset,
      );
      expect(
        sun.sunrise!.hour * 60 + sun.sunrise!.minute,
        closeTo(_minutes('05:49'), 2),
      );
      expect(
        sun.sunset!.hour * 60 + sun.sunset!.minute,
        closeTo(_minutes('18:57'), 2),
      );
      expect(
        sun.eveningGoldenHour!.end.isAfter(sun.eveningGoldenHour!.start),
        isTrue,
      );
    });

    test('a known full moon is reported as full', () {
      // Full moon of 26 Sep 2026, ~16:49 UTC.
      final moon = moonPhaseAt(DateTime.utc(2026, 9, 26, 17));
      expect(moon.name, MoonPhaseName.fullMoon);
      expect(moon.illumination, greaterThan(0.97));
    });
  });
}
