part of 'alerts_bloc.dart';

final class AlertsState extends Equatable {
  const AlertsState({
    this.status = LoadStatus.initial,
    this.alerts = const <WeatherAlert>[],
    this.ownPlace,
    this.failure,
  });

  final LoadStatus status;

  /// Most severe first, then soonest.
  final List<WeatherAlert> alerts;
  final Place? ownPlace;
  final DataFailure? failure;

  List<WeatherAlert> get ownAlerts {
    final own = ownPlace;
    if (own == null) return const <WeatherAlert>[];
    return alerts.where((a) => a.place.key == own.key).toList();
  }

  /// Everything else, so the user's own alerts are not listed twice.
  List<WeatherAlert> get regionAlerts {
    final own = ownPlace;
    if (own == null) return alerts;
    return alerts.where((a) => a.place.key != own.key).toList();
  }

  @override
  List<Object?> get props => <Object?>[status, alerts, ownPlace, failure];
}
