part of 'favorites_bloc.dart';

final class FavoritesState extends Equatable {
  const FavoritesState({this.places = const <Place>[]});

  final List<Place> places;

  bool contains(Place place) => places.any((saved) => saved.key == place.key);

  @override
  List<Object?> get props => <Object?>[places];
}
