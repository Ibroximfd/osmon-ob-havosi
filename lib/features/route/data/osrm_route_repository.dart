import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/domain/place_time.dart';
import '../../../core/domain/weather_condition.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/route_models.dart';
import '../domain/route_repository.dart';

final class OsrmRouteRepository implements RouteRepository {
  const OsrmRouteRepository(this._http, this._prefs);

  final Dio _http;
  final SharedPreferences _prefs;

  static const String _savedKey = 'v2.saved_routes';

  /// Inter-city roads in the region: about 1.25× the straight distance at
  /// an average 70 km/h — the fallback estimate when OSRM is unavailable.
  static const double _roadFactor = 1.25;
  static const double _averageSpeedKmh = 70;
  static const Duration _geocodeTimeout = Duration(seconds: 4);

  @override
  Future<Either<DataFailure, RoutePath>> findPath(Place from, Place to) async {
    final result = await guard(() => _osrm(from.point, to.point));
    return result.fold((failure) {
      if (failure is OfflineFailure) {
        return const Left<DataFailure, RoutePath>(OfflineFailure());
      }
      return Right<DataFailure, RoutePath>(_estimate(from.point, to.point));
    }, Right<DataFailure, RoutePath>.new);
  }

  Future<RoutePath> _osrm(GeoPoint from, GeoPoint to) async {
    final coordinates =
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
    final response = await _http.get<Map<String, dynamic>>(
      '${ApiEndpoints.osrmRoute}/$coordinates',
      queryParameters: const <String, String>{
        'overview': 'simplified',
        'geometries': 'geojson',
      },
    );
    final json = response.data ?? (throw const FormatException('empty route'));
    final routes = json.list('routes');
    if (routes.isEmpty) throw const FormatException('no route');
    final route = routes.first as Map<String, dynamic>;
    final coordinatesList = route.object('geometry').list('coordinates');
    return RoutePath(
      points: <GeoPoint>[
        for (final pair in coordinatesList.whereType<List<dynamic>>())
          GeoPoint(pair.numberAt(1), pair.numberAt(0)),
      ],
      distanceKm: route.number('distance') / 1000,
      duration: Duration(seconds: route.number('duration').round()),
      isEstimated: false,
    );
  }

  RoutePath _estimate(GeoPoint from, GeoPoint to) {
    final distance = from.distanceKmTo(to) * _roadFactor;
    return RoutePath(
      points: <GeoPoint>[from, to],
      distanceKm: distance,
      duration: Duration(minutes: (distance / _averageSpeedKmh * 60).round()),
      isEstimated: true,
    );
  }

  @override
  Future<Either<DataFailure, List<PointForecast>>> loadPointForecasts(
    List<GeoPoint> points,
  ) => guard(() async {
    final response = await _http.get<Object>(
      ApiEndpoints.forecast,
      queryParameters: <String, Object>{
        'latitude': points.map((p) => p.latitude.toStringAsFixed(4)).join(','),
        'longitude': points
            .map((p) => p.longitude.toStringAsFixed(4))
            .join(','),
        'hourly':
            'temperature_2m,weather_code,precipitation_probability,'
            'visibility,wind_gusts_10m,snowfall,is_day',
        'forecast_days': 3,
        'timezone': 'auto',
      },
    );
    final data = response.data;
    // One location answers with an object, several with a list.
    final locations = data is List<dynamic>
        ? data.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[if (data is Map<String, dynamic>) data];
    return locations.map(_pointForecast).toList(growable: false);
  });

  static PointForecast _pointForecast(Map<String, dynamic> json) {
    final h = json.object('hourly');
    final times = h.list('time');
    return PointForecast(
      utcOffsetSeconds: json.number('utc_offset_seconds').round(),
      hours: <PointHour>[
        // Trailing hours past the model horizon are null; a null read as
        // 0 °C would invent ice warnings, so they are dropped.
        for (
          var i = 0;
          i < times.length &&
              h.list('temperature_2m').numberOrNullAt(i) != null;
          i++
        )
          PointHour(
            time: parsePlaceTime(times.textAt(i)),
            temperature: h.list('temperature_2m').numberOrNullAt(i) ?? 0,
            condition: WeatherCondition.fromWmo(
              (h.list('weather_code').numberOrNullAt(i) ?? 0).round(),
            ),
            precipitationProbability:
                h.list('precipitation_probability').numberOrNullAt(i) ?? 0,
            visibility: h.list('visibility').numberOrNullAt(i) ?? 0,
            windGusts: h.list('wind_gusts_10m').numberOrNullAt(i) ?? 0,
            snowfall: h.list('snowfall').numberOrNullAt(i) ?? 0,
            isDay: h.list('is_day').numberOrNullAt(i) == 1,
          ),
      ],
    );
  }

  @override
  Future<String?> nameOf(GeoPoint point, {required String languageCode}) async {
    try {
      await setLocaleIdentifier(languageCode);
      final marks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      ).timeout(_geocodeTimeout);
      if (marks.isEmpty) return null;
      final mark = marks.first;
      for (final candidate in <String?>[
        mark.locality,
        mark.subAdministrativeArea,
        mark.administrativeArea,
      ]) {
        if (candidate != null && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
      return null;
    } on TimeoutException {
      return null;
    } on NoResultFoundException {
      return null;
    }
  }

  @override
  List<SavedRoute> get savedRoutes {
    final raw = _prefs.getStringList(_savedKey) ?? const <String>[];
    return raw.map(_decode).whereType<SavedRoute>().toList();
  }

  @override
  Future<void> toggleSaved(SavedRoute route) async {
    final current = savedRoutes;
    final exists = current.any((r) => r.key == route.key);
    final next = exists
        ? current.where((r) => r.key != route.key).toList()
        : <SavedRoute>[route, ...current];
    await _prefs.setStringList(
      _savedKey,
      next
          .map(
            (r) => jsonEncode(<String, Object?>{
              'from': r.from.toJson(),
              'to': r.to.toJson(),
            }),
          )
          .toList(),
    );
  }

  static SavedRoute? _decode(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) return null;
    final from = json['from'];
    final to = json['to'];
    if (from is! Map<String, dynamic> || to is! Map<String, dynamic>) {
      return null;
    }
    final origin = Place.fromJson(from);
    final destination = Place.fromJson(to);
    if (origin == null || destination == null) return null;
    return SavedRoute(origin, destination);
  }
}
