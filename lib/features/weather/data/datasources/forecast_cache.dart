import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the last forecast payload (one place) so the app opens offline.
final class ForecastCache {
  const ForecastCache(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'v2.forecast_cache';

  Future<void> write(
    String placeKey,
    Map<String, dynamic> forecast,
    Map<String, dynamic>? air,
  ) => _prefs.setString(
    _key,
    jsonEncode(<String, Object?>{
      'place': placeKey,
      'forecast': forecast,
      'air': air,
    }),
  );

  /// Null when nothing is cached for [placeKey].
  ({Map<String, dynamic> forecast, Map<String, dynamic>? air})? read(
    String placeKey,
  ) {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['place'] != placeKey) {
      return null;
    }
    final forecast = decoded['forecast'];
    if (forecast is! Map<String, dynamic>) return null;
    final air = decoded['air'];
    return (forecast: forecast, air: air is Map<String, dynamic> ? air : null);
  }
}
