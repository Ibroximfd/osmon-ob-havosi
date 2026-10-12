part of 'place_search_bloc.dart';

sealed class PlaceSearchEvent extends Equatable {
  const PlaceSearchEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PlaceQueryChanged extends PlaceSearchEvent {
  const PlaceQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}
