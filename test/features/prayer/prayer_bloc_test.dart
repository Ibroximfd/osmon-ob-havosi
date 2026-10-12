import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/bloc/load_status.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/time/tz_time_zone_resolver.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/data/adhan_prayer_times_source.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/domain/prayer_day.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/presentation/bloc/prayer_bloc.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../helpers/fakes.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  PrayerBloc build(DateTime utcNow) => PrayerBloc(
    location: FakeLocationRepository(selected: UzbekCities.tashkent),
    settings: FakeSettingsRepository(),
    times: const AdhanPrayerTimesSource(),
    timeZones: const TzTimeZoneResolver(),
    clock: () => utcNow,
    tick: const Duration(hours: 1),
  );

  blocTest<PrayerBloc, PrayerState>(
    'mid-morning in Tashkent the next prayer is dhuhr',
    // 10:00 Tashkent time.
    build: () => build(DateTime.utc(2026, 9, 1, 5)),
    act: (bloc) => bloc.add(const PrayerStarted()),
    verify: (bloc) {
      final state = bloc.state;
      expect(state.status, LoadStatus.ready);
      expect(state.next!.key, Prayer.dhuhr);
      expect(state.current, Prayer.fajr);
      expect(state.untilNext!.inMinutes, closeTo(143, 3));
      expect(state.progressToNext, inInclusiveRange(0, 1));
    },
  );

  blocTest<PrayerBloc, PrayerState>(
    'after isha the next prayer is tomorrow\'s fajr',
    // 22:30 Tashkent time.
    build: () => build(DateTime.utc(2026, 9, 1, 17, 30)),
    act: (bloc) => bloc.add(const PrayerStarted()),
    verify: (bloc) {
      expect(bloc.state.next!.key, Prayer.fajr);
      expect(bloc.state.next!.value.day, 2);
    },
  );
}
