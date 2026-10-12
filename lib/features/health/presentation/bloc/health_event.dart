part of 'health_bloc.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class HealthRequested extends HealthEvent {
  const HealthRequested();
}
