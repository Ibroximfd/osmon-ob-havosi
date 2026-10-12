import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/error/data_failure.dart';
import '../../../../core/theme/osmon_motion.dart';
import '../../../location/domain/location_repository.dart';
import '../../domain/map_repository.dart';
import '../../domain/weather_grid.dart';

part 'map_event.dart';
part 'map_state.dart';

/// Drives one map: the tile source, the weather grid for the visible area
/// and the precipitation timeline. The Map and Radar tabs each own one.
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required MapRepository repository,
    required LocationRepository location,
    MapLayer initialLayer = MapLayer.temperature,
    Duration viewportDebounce = OsmonMotion.mapDebounce,
    Duration playbackFrame = OsmonMotion.radarFrame,
  }) : _repository = repository,
       _location = location,
       _playbackFrame = playbackFrame,
       super(MapState(layer: initialLayer, focus: location.selectedPlace)) {
    on<MapStarted>(_onStarted);
    on<MapViewportChanged>(
      _onViewportChanged,
      transformer: (events, mapper) =>
          events.debounce(viewportDebounce).switchMap(mapper),
    );
    on<MapLayerSelected>(_onLayerSelected, transformer: restartable());
    on<MapTimelineStepSelected>(
      (event, emit) => emit(state.copyWith(step: event.step, isPlaying: false)),
    );
    on<MapPlaybackToggled>(_onPlaybackToggled);
    on<_MapPlaybackTicked>(_onPlaybackTicked);
    on<_MapFocusChanged>(
      (event, emit) => emit(
        state.copyWith(
          focus: event.place,
          focusRevision: state.focusRevision + 1,
        ),
      ),
    );
    _placeSubscription = _location.watchSelectedPlace().listen(
      (place) => add(_MapFocusChanged(place)),
    );
  }

  final MapRepository _repository;
  final LocationRepository _location;
  final Duration _playbackFrame;
  late final StreamSubscription<Place> _placeSubscription;
  StreamSubscription<void>? _playback;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    final result = await _repository.resolveTileTemplate();
    result.fold(
      (failure) => emit(state.copyWith(tileFailure: failure)),
      (template) => emit(state.copyWith(tileTemplate: template)),
    );
  }

  Future<void> _onViewportChanged(
    MapViewportChanged event,
    Emitter<MapState> emit,
  ) async {
    final previous = state.grid?.bounds;
    if (previous != null &&
        previous.roughlyEquals(event.bounds) &&
        state.status == LoadStatus.ready) {
      return;
    }
    await _loadGrid(event.bounds, emit);
  }

  Future<void> _onLayerSelected(
    MapLayerSelected event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(layer: event.layer, isPlaying: false));
    _stopPlayback();
    final bounds = state.lastBounds;
    final needsAir =
        event.layer == MapLayer.airQuality &&
        !(state.grid?.cells.any((c) => c.usAqi != null) ?? false);
    if (bounds != null && needsAir) await _loadGrid(bounds, emit);
  }

  Future<void> _loadGrid(GeoBounds bounds, Emitter<MapState> emit) async {
    emit(state.copyWith(status: LoadStatus.loading, lastBounds: bounds));
    final result = await _repository.loadGrid(
      bounds,
      named: UzbekCities.regionalCentres,
      withAirQuality: state.layer == MapLayer.airQuality,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: failure is OfflineFailure
              ? LoadStatus.offline
              : LoadStatus.failure,
          failure: failure,
        ),
      ),
      (grid) => emit(
        state.copyWith(
          status: LoadStatus.ready,
          grid: grid,
          step: state.step.clamp(
            0,
            grid.stepTimes.isEmpty ? 0 : grid.stepTimes.length - 1,
          ),
        ),
      ),
    );
  }

  void _onPlaybackToggled(MapPlaybackToggled event, Emitter<MapState> emit) {
    if (state.isPlaying) {
      _stopPlayback();
      emit(state.copyWith(isPlaying: false));
      return;
    }
    _playback = Stream<void>.periodic(
      _playbackFrame,
    ).listen((_) => add(const _MapPlaybackTicked()));
    emit(state.copyWith(isPlaying: true));
  }

  void _onPlaybackTicked(_MapPlaybackTicked event, Emitter<MapState> emit) {
    final steps = state.grid?.stepTimes.length ?? 0;
    if (steps == 0) return;
    emit(state.copyWith(step: (state.step + 1) % steps));
  }

  void _stopPlayback() {
    _playback?.cancel();
    _playback = null;
  }

  @override
  Future<void> close() {
    _stopPlayback();
    _placeSubscription.cancel();
    return super.close();
  }
}
