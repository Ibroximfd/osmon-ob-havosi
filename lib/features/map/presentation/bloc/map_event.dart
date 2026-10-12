part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class MapStarted extends MapEvent {
  const MapStarted();
}

/// The camera settled on a new visible area.
final class MapViewportChanged extends MapEvent {
  const MapViewportChanged(this.bounds);

  final GeoBounds bounds;

  @override
  List<Object?> get props => <Object?>[bounds];
}

final class MapLayerSelected extends MapEvent {
  const MapLayerSelected(this.layer);

  final MapLayer layer;

  @override
  List<Object?> get props => <Object?>[layer];
}

final class MapTimelineStepSelected extends MapEvent {
  const MapTimelineStepSelected(this.step);

  final int step;

  @override
  List<Object?> get props => <Object?>[step];
}

final class MapPlaybackToggled extends MapEvent {
  const MapPlaybackToggled();
}

final class _MapPlaybackTicked extends MapEvent {
  const _MapPlaybackTicked();
}

final class _MapFocusChanged extends MapEvent {
  const _MapFocusChanged(this.place);

  final Place place;

  @override
  List<Object?> get props => <Object?>[place];
}
