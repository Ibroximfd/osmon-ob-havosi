import '../../../core/domain/place.dart';

/// Saved places, stored locally. Writes cannot fail in an expected way.
abstract interface class FavoritesRepository {
  List<Place> get all;

  Stream<List<Place>> watch();

  Future<void> toggle(Place place);
}
