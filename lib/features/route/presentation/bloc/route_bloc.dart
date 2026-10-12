import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/domain/place_time.dart';
import '../../../../core/error/data_failure.dart';
import '../../../location/domain/location_repository.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/route_models.dart';
import '../../domain/route_planner.dart';
import '../../domain/route_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc({
    required RouteRepository routes,
    required LocationRepository location,
    required SettingsRepository settings,
    Clock clock = systemClock,
  }) : _routes = routes,
       _settings = settings,
       _clock = clock,
       super(
         RouteState(from: location.selectedPlace, saved: routes.savedRoutes),
       ) {
    on<RouteOriginChosen>(
      (event, emit) => _replan(emit, state.copyWith(from: event.place)),
      transformer: restartable(),
    );
    on<RouteDestinationChosen>(
      (event, emit) => _replan(emit, state.copyWith(to: event.place)),
      transformer: restartable(),
    );
    on<RouteSwapped>(
      (event, emit) => _replan(emit, state.swapped()),
      transformer: restartable(),
    );
    on<RouteDepartureChosen>(
      (event, emit) => _replan(emit, state.copyWith(departure: event.option)),
      transformer: restartable(),
    );
    on<RouteSavedChosen>(
      (event, emit) => _replan(
        emit,
        state.copyWith(from: event.route.from, to: event.route.to),
      ),
      transformer: restartable(),
    );
    on<RouteRetried>(
      (event, emit) => _replan(emit, state),
      transformer: restartable(),
    );
    on<RouteSaveToggled>(_onSaveToggled, transformer: droppable());
  }

  final RouteRepository _routes;
  final SettingsRepository _settings;
  final Clock _clock;

  Future<void> _replan(Emitter<RouteState> emit, RouteState next) async {
    final from = next.from;
    final to = next.to;
    if (from == null || to == null || from.key == to.key) {
      emit(next.withoutPlan(LoadStatus.initial));
      return;
    }
    emit(next.withoutPlan(LoadStatus.loading));

    final pathResult = await _routes.findPath(from, to);
    final path = pathResult.fold((_) => null, (value) => value);
    if (path == null) {
      emit(
        next.failed(pathResult.fold((f) => f, (_) => const ServerFailure())),
      );
      return;
    }
    final samples = sampleCheckpoints(path);
    final weatherResult = await _routes.loadPointForecasts(
      samples.map((s) => s.point).toList(),
    );
    final forecasts = weatherResult.fold((_) => null, (value) => value);
    if (forecasts == null || forecasts.isEmpty) {
      emit(
        next.failed(weatherResult.fold((f) => f, (_) => const ServerFailure())),
      );
      return;
    }
    final originOffset = forecasts.first.utcOffsetSeconds;
    final plan = buildPlan(
      from: from,
      to: to,
      path: path,
      departure: next.departure.resolve(placeNow(originOffset, clock: _clock)),
      originOffsetSeconds: originOffset,
      samples: samples,
      forecasts: forecasts,
    );
    emit(next.ready(plan));
    await _nameCheckpoints(plan, emit);
  }

  /// Names arrive one by one so the list fills in while the user reads.
  Future<void> _nameCheckpoints(
    RoutePlan plan,
    Emitter<RouteState> emit,
  ) async {
    final language = _settings.current.languageCode ?? 'uz';
    final named = List<RouteCheckpoint>.of(plan.checkpoints);
    for (var i = 1; i < named.length - 1; i++) {
      final name = await _routes.nameOf(named[i].point, languageCode: language);
      if (emit.isDone) return;
      if (name == null) continue;
      named[i] = named[i].withName(name);
      emit(
        state.ready(
          RoutePlan(
            from: plan.from,
            to: plan.to,
            path: plan.path,
            departure: plan.departure,
            checkpoints: List<RouteCheckpoint>.unmodifiable(named),
            betterDelay: plan.betterDelay,
          ),
        ),
      );
    }
  }

  Future<void> _onSaveToggled(
    RouteSaveToggled event,
    Emitter<RouteState> emit,
  ) async {
    final from = state.from;
    final to = state.to;
    if (from == null || to == null) return;
    await _routes.toggleSaved(SavedRoute(from, to));
    emit(state.copyWith(saved: _routes.savedRoutes));
  }
}
