import 'package:equatable/equatable.dart';

enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// The five daily prayers plus sunrise (the end of the fajr window), in
/// place wall-clock time.
final class PrayerDay extends Equatable {
  const PrayerDay({required this.date, required this.times});

  final DateTime date;
  final Map<Prayer, DateTime> times;

  DateTime operator [](Prayer prayer) => times[prayer]!;

  /// Entries in day order, sunrise included.
  List<MapEntry<Prayer, DateTime>> get ordered => <MapEntry<Prayer, DateTime>>[
    for (final prayer in Prayer.values) MapEntry(prayer, this[prayer]),
  ];

  @override
  List<Object?> get props => <Object?>[date, times];
}
