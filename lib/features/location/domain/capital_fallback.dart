import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';

/// When location is refused, show the capital of the device's region rather
/// than an empty screen — the right city for most people in the region.
/// Any other region gets Tashkent, so no screen ever waits for a place.
Place capitalFor(String? regionCode) => switch (regionCode?.toUpperCase()) {
  'UZ' => UzbekCities.tashkent,
  'KZ' => const Place(
    name: 'Astana',
    point: GeoPoint(51.1694, 71.4491),
    countryCode: 'KZ',
    timezoneId: 'Asia/Almaty',
  ),
  'KG' => const Place(
    name: 'Bishkek',
    point: GeoPoint(42.8746, 74.5698),
    countryCode: 'KG',
    timezoneId: 'Asia/Bishkek',
  ),
  'TJ' => const Place(
    name: 'Dushanbe',
    point: GeoPoint(38.5598, 68.7870),
    countryCode: 'TJ',
    timezoneId: 'Asia/Dushanbe',
  ),
  'RU' => const Place(
    name: 'Moskva',
    point: GeoPoint(55.7558, 37.6173),
    countryCode: 'RU',
    timezoneId: 'Europe/Moscow',
  ),
  _ => UzbekCities.tashkent,
};
