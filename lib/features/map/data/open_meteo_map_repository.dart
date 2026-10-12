import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/domain/place_time.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/map_repository.dart';
import '../domain/weather_grid.dart';

final class OpenMeteoMapRepository implements MapRepository {
  const OpenMeteoMapRepository(this._http, this._prefs);

  final Dio _http;
  final SharedPreferences _prefs;

  static const String _templateKey = 'v2.map_tile_template';
  static const int _columns = 6;
  static const int _rows = 8;
  static const int _steps = 9;

  @override
  Future<Either<DataFailure, String>> resolveTileTemplate() async {
    final result = await guard(() async {
      final response = await _http.get<Map<String, dynamic>>(
        ApiEndpoints.openFreeMapTileJson,
      );
      final json = response.data ?? (throw const FormatException('tilejson'));
      final tiles = json.list('tiles');
      if (tiles.isEmpty) throw const FormatException('no tiles');
      return tiles.textAt(0);
    });
    return result.fold(
      (failure) {
        final cached = _prefs.getString(_templateKey);
        return cached == null
            ? Left<DataFailure, String>(failure)
            : Right<DataFailure, String>(cached);
      },
      (template) {
        _prefs.setString(_templateKey, template);
        return Right<DataFailure, String>(template);
      },
    );
  }

  @override
  Future<Either<DataFailure, WeatherGrid>> loadGrid(
    GeoBounds bounds, {
    required List<Place> named,
    required bool withAirQuality,
  }) => guard(() async {
    final inside = named.where((p) => bounds.contains(p.point)).toList();
    final points = <GeoPoint>[
      ...inside.map((p) => p.point),
      ...bounds.grid(columns: _columns, rows: _rows),
    ];
    final coordinates = <String, String>{
      'latitude': points.map((p) => p.latitude.toStringAsFixed(3)).join(','),
      'longitude': points.map((p) => p.longitude.toStringAsFixed(3)).join(','),
    };
    final forecastFuture = _http.get<Object>(
      ApiEndpoints.forecast,
      queryParameters: <String, Object>{
        ...coordinates,
        'current':
            'temperature_2m,wind_speed_10m,wind_direction_10m,cloud_cover',
        'minutely_15': 'precipitation',
        'forecast_minutely_15': _steps,
        'timezone': 'auto',
      },
    );
    final airFuture = withAirQuality
        ? _http
              .get<Object>(
                ApiEndpoints.airQuality,
                queryParameters: <String, Object>{
                  ...coordinates,
                  'current': 'us_aqi',
                },
              )
              .then<Object?>((response) => response.data)
        : Future<Object?>.value();

    final forecasts = _locations((await forecastFuture).data);
    final air = _locations(await airFuture);
    final cells = <GridCell>[
      for (var i = 0; i < points.length && i < forecasts.length; i++)
        _cell(
          points[i],
          forecasts[i],
          i < air.length ? air[i] : null,
          i < inside.length ? inside[i] : null,
        ),
    ];
    final stepTimes = forecasts.isEmpty
        ? const <DateTime>[]
        : _stepTimes(forecasts.first);
    return WeatherGrid(bounds: bounds, cells: cells, stepTimes: stepTimes);
  });

  static List<Map<String, dynamic>> _locations(Object? data) => data is List
      ? data.whereType<Map<String, dynamic>>().toList()
      : <Map<String, dynamic>>[if (data is Map<String, dynamic>) data];

  static GridCell _cell(
    GeoPoint point,
    Map<String, dynamic> json,
    Map<String, dynamic>? air,
    Place? place,
  ) {
    final current = json.object('current');
    final steps = json.objectOrNull('minutely_15')?.listOrNull('precipitation');
    return GridCell(
      point: point,
      temperature: current.number('temperature_2m'),
      windSpeed: current.numberOrNull('wind_speed_10m') ?? 0,
      windDirection: current.numberOrNull('wind_direction_10m') ?? 0,
      cloudCover: current.numberOrNull('cloud_cover') ?? 0,
      precipitationSteps: <double>[
        for (var i = 0; i < _steps; i++) steps?.numberOrNullAt(i) ?? 0,
      ],
      usAqi: air?.objectOrNull('current')?.numberOrNull('us_aqi'),
      place: place,
    );
  }

  static List<DateTime> _stepTimes(Map<String, dynamic> json) {
    final times =
        json.objectOrNull('minutely_15')?.listOrNull('time') ??
        const <dynamic>[];
    return <DateTime>[
      for (var i = 0; i < times.length; i++) parsePlaceTime(times.textAt(i)),
    ];
  }
}
