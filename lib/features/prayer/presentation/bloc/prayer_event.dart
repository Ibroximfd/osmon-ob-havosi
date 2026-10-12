part of 'prayer_bloc.dart';

sealed class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PrayerStarted extends PrayerEvent {
  const PrayerStarted();
}

final class _PrayerContextChanged extends PrayerEvent {
  const _PrayerContextChanged();
}

final class _PrayerTicked extends PrayerEvent {
  const _PrayerTicked();
}
