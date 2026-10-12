part of 'route_bloc.dart';

sealed class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class RouteOriginChosen extends RouteEvent {
  const RouteOriginChosen(this.place);

  final Place place;

  @override
  List<Object?> get props => <Object?>[place];
}

final class RouteDestinationChosen extends RouteEvent {
  const RouteDestinationChosen(this.place);

  final Place place;

  @override
  List<Object?> get props => <Object?>[place];
}

final class RouteSwapped extends RouteEvent {
  const RouteSwapped();
}

final class RouteDepartureChosen extends RouteEvent {
  const RouteDepartureChosen(this.option);

  final DepartureOption option;

  @override
  List<Object?> get props => <Object?>[option];
}

final class RouteSavedChosen extends RouteEvent {
  const RouteSavedChosen(this.route);

  final SavedRoute route;

  @override
  List<Object?> get props => <Object?>[route];
}

final class RouteRetried extends RouteEvent {
  const RouteRetried();
}

final class RouteSaveToggled extends RouteEvent {
  const RouteSaveToggled();
}
