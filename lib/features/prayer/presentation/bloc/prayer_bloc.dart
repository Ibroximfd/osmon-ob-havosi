import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/domain/place_time.dart';
import '../../../../core/domain/time_zone_resolver.dart';
import '../../../../core/theme/osmon_motion.dart';
import '../../../location/domain/location_repository.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/astronomy.dart';
import '../../domain/prayer_day.dart';
import '../../domain/prayer_times_source.dart';

part 'prayer_event.dart';
part 'prayer_state.dart';

/// Computes everything offline; a periodic tick keeps the countdown live.
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  PrayerBloc({
    required LocationRepository location,
    required SettingsRepository settings,
    required PrayerTimesSource times,
    required TimeZoneResolver timeZones,
    Clock clock = systemClock,
    Duration tick = OsmonMotion.clockTick,
  }) : _location = location,
       _settings = settings,
       _times = times,
       _timeZones = timeZones,
       _clock = clock,
       super(const PrayerState()) {
    on<PrayerStarted>((event, emit) => _compute(emit));
    on<_PrayerContextChanged>((event, emit) => _compute(emit));
    on<_PrayerTicked>(_onTicked);
    _subscriptions = <StreamSubscription<Object?>>[
      _location.watchSelectedPlace().listen(
        (_) => add(const _PrayerContextChanged()),
      ),
      _settings.watch().listen((next) {
        if (next.prayerMethod != state.method) {
          add(const _PrayerContextChanged());
        }
      }),
      Stream<void>.periodic(tick).listen((_) => add(const _PrayerTicked())),
    ];
  }

  final LocationRepository _location;
  final SettingsRepository _settings;
  final PrayerTimesSource _times;
  final TimeZoneResolver _timeZones;
  final Clock _clock;
  late final List<StreamSubscription<Object?>> _subscriptions;

  void _compute(Emitter<PrayerState> emit) {
    final place = _location.selectedPlace;
    if (place == null) {
      emit(const PrayerState(status: LoadStatus.empty));
      return;
    }
    final utcNow = _clock().toUtc();
    final offset = _timeZones.offsetSecondsFor(place.timezoneId, utcNow);
    final now = utcNow.add(Duration(seconds: offset));
    final method = _settings.current.prayerMethod;
    PrayerDay dayAt(DateTime date) => _times.timesFor(
      point: place.point,
      date: date,
      utcOffsetSeconds: offset,
      method: method,
    );
    final today = now.dateOnly;
    emit(
      PrayerState(
        status: LoadStatus.ready,
        place: place,
        method: method,
        utcOffsetSeconds: offset,
        now: now,
        today: dayAt(today),
        tomorrow: dayAt(today.add(const Duration(days: 1))),
        sun: sunDayFor(place.point, today, offset),
        moon: moonPhaseAt(utcNow),
      ),
    );
  }

  void _onTicked(_PrayerTicked event, Emitter<PrayerState> emit) {
    final today = state.today;
    if (today == null) return;
    final now = _clock().toUtc().add(Duration(seconds: state.utcOffsetSeconds));
    if (!now.isSameDayAs(today.date)) {
      _compute(emit);
      return;
    }
    emit(state.copyWith(now: now));
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
