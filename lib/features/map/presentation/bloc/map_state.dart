part of 'map_bloc.dart';

final class MapState extends Equatable {
  const MapState({
    required this.layer,
    this.status = LoadStatus.initial,
    this.focus,
    this.focusRevision = 0,
    this.tileTemplate,
    this.tileFailure,
    this.grid,
    this.lastBounds,
    this.failure,
    this.step = 0,
    this.isPlaying = false,
  });

  final LoadStatus status;
  final MapLayer layer;

  /// The place the camera should centre on.
  final Place? focus;

  /// Bumped when [focus] changes so the map moves even to an equal place.
  final int focusRevision;
  final String? tileTemplate;
  final DataFailure? tileFailure;
  final WeatherGrid? grid;
  final GeoBounds? lastBounds;
  final DataFailure? failure;

  /// Index into `grid.stepTimes` for the precipitation layer.
  final int step;
  final bool isPlaying;

  DateTime? get stepTime {
    final times = grid?.stepTimes ?? const <DateTime>[];
    return step < times.length ? times[step] : null;
  }

  MapState copyWith({
    LoadStatus? status,
    MapLayer? layer,
    Place? focus,
    int? focusRevision,
    String? tileTemplate,
    DataFailure? tileFailure,
    WeatherGrid? grid,
    GeoBounds? lastBounds,
    DataFailure? failure,
    int? step,
    bool? isPlaying,
  }) => MapState(
    status: status ?? this.status,
    layer: layer ?? this.layer,
    focus: focus ?? this.focus,
    focusRevision: focusRevision ?? this.focusRevision,
    tileTemplate: tileTemplate ?? this.tileTemplate,
    tileFailure: tileFailure ?? this.tileFailure,
    grid: grid ?? this.grid,
    lastBounds: lastBounds ?? this.lastBounds,
    failure: failure,
    step: step ?? this.step,
    isPlaying: isPlaying ?? this.isPlaying,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    layer,
    focus,
    focusRevision,
    tileTemplate,
    tileFailure,
    grid,
    lastBounds,
    failure,
    step,
    isPlaying,
  ];
}
