part of 'alerts_bloc.dart';

sealed class AlertsEvent extends Equatable {
  const AlertsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AlertsRequested extends AlertsEvent {
  const AlertsRequested();
}
