part of 'route_bloc.dart';

enum DepartureOption {
  now,
  inOneHour,
  inTwoHours,
  inFourHours,
  tomorrowMorning;

  /// Departure in origin local time.
  DateTime resolve(DateTime now) => switch (this) {
    DepartureOption.now => now,
    DepartureOption.inOneHour => now.add(const Duration(hours: 1)),
    DepartureOption.inTwoHours => now.add(const Duration(hours: 2)),
    DepartureOption.inFourHours => now.add(const Duration(hours: 4)),
    DepartureOption.tomorrowMorning => now.dateOnly.add(
      const Duration(days: 1, hours: 7),
    ),
  };
}

final class RouteState extends Equatable {
  const RouteState({
    this.status = LoadStatus.initial,
    this.from,
    this.to,
    this.departure = DepartureOption.now,
    this.plan,
    this.failure,
    this.saved = const <SavedRoute>[],
  });

  final LoadStatus status;
  final Place? from;
  final Place? to;
  final DepartureOption departure;
  final RoutePlan? plan;
  final DataFailure? failure;
  final List<SavedRoute> saved;

  bool get isSaved {
    final origin = from;
    final destination = to;
    if (origin == null || destination == null) return false;
    final key = SavedRoute(origin, destination).key;
    return saved.any((route) => route.key == key);
  }

  RouteState copyWith({
    Place? from,
    Place? to,
    DepartureOption? departure,
    List<SavedRoute>? saved,
  }) => RouteState(
    status: status,
    from: from ?? this.from,
    to: to ?? this.to,
    departure: departure ?? this.departure,
    plan: plan,
    failure: failure,
    saved: saved ?? this.saved,
  );

  RouteState swapped() => RouteState(
    status: status,
    from: to,
    to: from,
    departure: departure,
    plan: plan,
    failure: failure,
    saved: saved,
  );

  RouteState withoutPlan(LoadStatus status) => RouteState(
    status: status,
    from: from,
    to: to,
    departure: departure,
    saved: saved,
  );

  RouteState failed(DataFailure failure) => RouteState(
    status: failure is OfflineFailure ? LoadStatus.offline : LoadStatus.failure,
    from: from,
    to: to,
    departure: departure,
    failure: failure,
    saved: saved,
  );

  RouteState ready(RoutePlan plan) => RouteState(
    status: LoadStatus.ready,
    from: from,
    to: to,
    departure: departure,
    plan: plan,
    saved: saved,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    from,
    to,
    departure,
    plan,
    failure,
    saved,
  ];
}
