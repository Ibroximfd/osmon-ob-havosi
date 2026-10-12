import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../domain/favorites_repository.dart';

final class PrefsFavoritesRepository implements FavoritesRepository {
  PrefsFavoritesRepository(this._prefs) : _places = _read(_prefs);

  final SharedPreferences _prefs;
  final StreamController<List<Place>> _changes =
      StreamController<List<Place>>.broadcast();
  List<Place> _places;

  static const String _key = 'v2.favorites';
  static const String _legacyKey = 'favorite_cities';

  @override
  List<Place> get all => List<Place>.unmodifiable(_places);

  @override
  Stream<List<Place>> watch() => _changes.stream;

  @override
  Future<void> toggle(Place place) async {
    final exists = _places.any((saved) => saved.key == place.key);
    _places = exists
        ? _places.where((saved) => saved.key != place.key).toList()
        : <Place>[..._places, place];
    _changes.add(all);
    await _prefs.setStringList(
      _key,
      _places.map((saved) => jsonEncode(saved.toJson())).toList(),
    );
  }

  static List<Place> _read(SharedPreferences prefs) {
    final stored = prefs.getStringList(_key);
    if (stored != null) return stored.map(_decode).whereType<Place>().toList();
    // 1.x saved {name, lat, lon}; Place.fromJson reads the same keys.
    final legacy = prefs.getStringList(_legacyKey) ?? const <String>[];
    return legacy.map(_decode).whereType<Place>().toList();
  }

  static Place? _decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final place = Place.fromJson(decoded);
    if (place == null) return null;
    // Favourites are named cities, never "my location".
    return Place(
      name: place.name,
      point: GeoPoint(place.point.latitude, place.point.longitude),
      region: place.region,
      countryCode: place.countryCode,
      timezoneId: place.timezoneId,
    );
  }
}
