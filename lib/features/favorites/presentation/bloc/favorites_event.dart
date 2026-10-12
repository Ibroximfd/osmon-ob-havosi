part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FavoriteToggled extends FavoritesEvent {
  const FavoriteToggled(this.place);

  final Place place;

  @override
  List<Object?> get props => <Object?>[place];
}

final class _FavoritesChanged extends FavoritesEvent {
  const _FavoritesChanged(this.places);

  final List<Place> places;

  @override
  List<Object?> get props => <Object?>[places];
}
