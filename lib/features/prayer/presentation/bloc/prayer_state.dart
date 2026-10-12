part of 'prayer_bloc.dart';

final class PrayerState extends Equatable {
  const PrayerState({
    this.status = LoadStatus.initial,
    this.place,
    this.method = PrayerMethod.uzbekistan,
    this.utcOffsetSeconds = 0,
    this.now,
    this.today,
    this.tomorrow,
    this.sun,
    this.moon,
  });

  final LoadStatus status;
  final Place? place;
  final PrayerMethod method;
  final int utcOffsetSeconds;

  /// Place wall-clock time of the last tick.
  final DateTime? now;
  final PrayerDay? today;
  final PrayerDay? tomorrow;
  final SunDay? sun;
  final MoonPhase? moon;

  static const List<Prayer> _prayers = <Prayer>[
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  /// The next of the five prayers (sunrise is not a prayer); after isha it
  /// is tomorrow's fajr.
  MapEntry<Prayer, DateTime>? get next {
    final current = now;
    final day = today;
    if (current == null || day == null) return null;
    for (final prayer in _prayers) {
      if (day[prayer].isAfter(current)) return MapEntry(prayer, day[prayer]);
    }
    final nextDay = tomorrow;
    return nextDay == null ? null : MapEntry(Prayer.fajr, nextDay[Prayer.fajr]);
  }

  /// The prayer whose time is running now, if any.
  Prayer? get current {
    final at = now;
    final day = today;
    if (at == null || day == null) return null;
    Prayer? latest;
    for (final prayer in _prayers) {
      if (!day[prayer].isAfter(at)) latest = prayer;
    }
    return latest;
  }

  Duration? get untilNext {
    final upcoming = next;
    final at = now;
    if (upcoming == null || at == null) return null;
    return upcoming.value.difference(at);
  }

  /// 0–1 of the way from the previous prayer to the next one.
  double get progressToNext {
    final upcoming = next;
    final at = now;
    final day = today;
    if (upcoming == null || at == null || day == null) return 0;
    final previous = current;
    final start = previous == null ? day.date : day[previous];
    final span = upcoming.value.difference(start).inSeconds;
    if (span <= 0) return 0;
    return (at.difference(start).inSeconds / span).clamp(0, 1).toDouble();
  }

  PrayerState copyWith({DateTime? now}) => PrayerState(
    status: status,
    place: place,
    method: method,
    utcOffsetSeconds: utcOffsetSeconds,
    now: now ?? this.now,
    today: today,
    tomorrow: tomorrow,
    sun: sun,
    moon: moon,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    place,
    method,
    utcOffsetSeconds,
    now,
    today,
    tomorrow,
    sun,
    moon,
  ];
}
