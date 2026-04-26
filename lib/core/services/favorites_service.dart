import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/city.dart';

class FavoritesService {
  static const _key = 'favorite_cities';

  final SharedPreferences _prefs;
  FavoritesService(this._prefs);

  List<City> getCities() {
    final raw = _prefs.getStringList(_key) ?? [];
    return raw.map((e) {
      final m = jsonDecode(e) as Map<String, dynamic>;
      return City(
        name: m['name'] as String,
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
      );
    }).toList();
  }

  Future<void> addCity(City city) async {
    final list = getCities();
    if (!list.any((c) => c.name == city.name)) {
      list.add(city);
      await _save(list);
    }
  }

  Future<void> removeCity(City city) async {
    final list = getCities().where((c) => c.name != city.name).toList();
    await _save(list);
  }

  bool isFavorite(String cityName) =>
      getCities().any((c) => c.name == cityName);

  Future<void> _save(List<City> list) async {
    await _prefs.setStringList(
      _key,
      list
          .map(
            (c) => jsonEncode({'name': c.name, 'lat': c.lat, 'lon': c.lon}),
          )
          .toList(),
    );
  }
}
