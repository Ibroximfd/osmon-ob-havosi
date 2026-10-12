import 'package:equatable/equatable.dart';

import 'geo_point.dart';

/// A location the user watches the weather for: their GPS position, a
/// searched city or a favourite.
final class Place extends Equatable {
  const Place({
    required this.name,
    required this.point,
    this.region,
    this.countryCode,
    this.timezoneId,
    this.isCurrentLocation = false,
  });

  final String name;
  final GeoPoint point;

  /// Province / oblast, shown under the name when known.
  final String? region;

  /// ISO 3166-1 alpha-2, upper case (`UZ`, `KZ`).
  final String? countryCode;

  /// IANA zone (`Asia/Tashkent`) — needed for prayer times of a searched
  /// city in another time zone.
  final String? timezoneId;

  /// True when the place came from GPS rather than a search.
  final bool isCurrentLocation;

  /// Stable identity for favourites: two searches of the same city match.
  String get key =>
      '${point.latitude.toStringAsFixed(2)},${point.longitude.toStringAsFixed(2)}';

  Place copyWith({String? name, String? region, String? timezoneId}) => Place(
    name: name ?? this.name,
    point: point,
    region: region ?? this.region,
    countryCode: countryCode,
    timezoneId: timezoneId ?? this.timezoneId,
    isCurrentLocation: isCurrentLocation,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'lat': point.latitude,
    'lon': point.longitude,
    'region': region,
    'country': countryCode,
    'tz': timezoneId,
    'gps': isCurrentLocation,
  };

  static Place? fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final lat = json['lat'];
    final lon = json['lon'];
    if (name is! String || lat is! num || lon is! num) return null;
    return Place(
      name: name,
      point: GeoPoint(lat.toDouble(), lon.toDouble()),
      region: json['region'] as String?,
      countryCode: json['country'] as String?,
      timezoneId: json['tz'] as String?,
      isCurrentLocation: json['gps'] == true,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    name,
    point,
    region,
    countryCode,
    timezoneId,
    isCurrentLocation,
  ];
}

/// Regional centres of Uzbekistan — the default places, the alert sweep and
/// the named markers on the map.
abstract final class UzbekCities {
  static const Place tashkent = Place(
    name: 'Toshkent',
    point: GeoPoint(41.2995, 69.2401),
    countryCode: 'UZ',
    timezoneId: 'Asia/Tashkent',
  );

  static const List<Place> regionalCentres = <Place>[
    tashkent,
    Place(
      name: 'Samarqand',
      point: GeoPoint(39.6270, 66.9749),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Buxoro',
      point: GeoPoint(39.7747, 64.4286),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Andijon',
      point: GeoPoint(40.7821, 72.3442),
      countryCode: 'UZ',
      timezoneId: 'Asia/Tashkent',
    ),
    Place(
      name: 'Namangan',
      point: GeoPoint(41.0011, 71.6676),
      countryCode: 'UZ',
      timezoneId: 'Asia/Tashkent',
    ),
    Place(
      name: "Farg'ona",
      point: GeoPoint(40.3842, 71.7843),
      countryCode: 'UZ',
      timezoneId: 'Asia/Tashkent',
    ),
    Place(
      name: 'Qarshi',
      point: GeoPoint(38.8606, 65.7891),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Termiz',
      point: GeoPoint(37.2242, 67.2783),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Navoiy',
      point: GeoPoint(40.0844, 65.3792),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Jizzax',
      point: GeoPoint(40.1158, 67.8422),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Guliston',
      point: GeoPoint(40.4897, 68.7842),
      countryCode: 'UZ',
      timezoneId: 'Asia/Tashkent',
    ),
    Place(
      name: 'Urganch',
      point: GeoPoint(41.5533, 60.6347),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Nukus',
      point: GeoPoint(42.4619, 59.6166),
      countryCode: 'UZ',
      timezoneId: 'Asia/Samarkand',
    ),
    Place(
      name: 'Nurafshon',
      point: GeoPoint(41.0167, 69.3417),
      countryCode: 'UZ',
      timezoneId: 'Asia/Tashkent',
    ),
  ];
}
