part of 'weather_bloc.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Events that (re)load the forecast. They share one restartable handler so
/// the newest request always wins, whatever triggered it.
sealed class WeatherLoadEvent extends WeatherEvent {
  const WeatherLoadEvent();
}

final class WeatherStarted extends WeatherLoadEvent {
  const WeatherStarted();
}

final class WeatherRefreshed extends WeatherLoadEvent {
  const WeatherRefreshed();
}

final class WeatherPlaceSelected extends WeatherLoadEvent {
  const WeatherPlaceSelected(this.place);

  final Place place;

  @override
  List<Object?> get props => <Object?>[place];
}

final class WeatherLocateRequested extends WeatherLoadEvent {
  const WeatherLocateRequested();
}

final class _SelectedPlaceChanged extends WeatherLoadEvent {
  const _SelectedPlaceChanged(this.place);

  final Place place;

  @override
  List<Object?> get props => <Object?>[place];
}

/// The user asked to fix location access; only the system screen can turn
/// location services back on.
final class WeatherLocationSettingsOpened extends WeatherEvent {
  const WeatherLocationSettingsOpened();
}

/// The app came back to the foreground — possibly from the system settings,
/// so location access may have changed.
final class WeatherAppResumed extends WeatherEvent {
  const WeatherAppResumed();
}
