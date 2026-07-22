import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/city.dart';

/// Joylashuvni GPS orqali bloklovchi UI'siz aniqlaydi.
///
/// Ruxsat/servis o'chiq bo'lsa `null` qaytaradi — chaqiruvchi taraf
/// [getFallbackCity] orqali oxirgi saqlangan joylashuv yoki standart
/// shahar (Toshkent) bilan davom etishi kerak.
class LocationService {
  static const _lastLatKey = 'last_known_lat';
  static const _lastLonKey = 'last_known_lon';
  static const _lastNameKey = 'last_known_city_name';

  /// GPS orqali joriy joylashuvni aniqlashga harakat qiladi.
  /// Muvaffaqiyatli bo'lsa natijani "oxirgi ma'lum joylashuv" sifatida saqlaydi.
  static Future<City?> resolveCurrentCity() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 3));
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 3));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );

      String cityName = "Sizning joylashuvingiz";
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 4));
        if (placemarks.isNotEmpty) {
          cityName = placemarks.first.locality ??
              placemarks.first.subAdministrativeArea ??
              placemarks.first.administrativeArea ??
              cityName;
        }
      } catch (_) {}

      final city = City(
        name: cityName,
        lat: position.latitude,
        lon: position.longitude,
      );
      await _saveLastKnownCity(city);
      return city;
    } catch (_) {
      return null;
    }
  }

  /// GPS mavjud bo'lmaganda ishlatiladigan zaxira: oxirgi saqlangan
  /// joylashuv, u ham bo'lmasa standart shahar (Toshkent).
  static Future<City> getFallbackCity() async {
    final last = await getLastKnownCity();
    return last ?? City.cities[0];
  }

  static Future<City?> getLastKnownCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_lastLatKey);
    final lon = prefs.getDouble(_lastLonKey);
    final name = prefs.getString(_lastNameKey);
    if (lat == null || lon == null || name == null) return null;
    return City(name: name, lat: lat, lon: lon);
  }

  static Future<void> _saveLastKnownCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastLatKey, city.lat);
    await prefs.setDouble(_lastLonKey, city.lon);
    await prefs.setString(_lastNameKey, city.name);
  }

  /// "Yoqish" tugmasi bosilganda mos sozlamalar ekranini ochadi.
  static Future<void> openLocationSettings() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }
}
