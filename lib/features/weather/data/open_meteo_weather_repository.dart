import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/domain/place.dart';
import '../../../core/domain/place_time.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/entities/forecast.dart';
import '../domain/weather_repository.dart';
import 'datasources/forecast_cache.dart';
import 'datasources/forecast_remote_source.dart';
import 'models/forecast_mapper.dart';

/// Network-first: a fresh forecast is always attempted and then cached; the
/// cache is only read when the caller falls back after an offline failure.
final class OpenMeteoWeatherRepository implements WeatherRepository {
  const OpenMeteoWeatherRepository(
    this._remote,
    this._cache, {
    Clock clock = systemClock,
  }) : _clock = clock;

  final ForecastRemoteSource _remote;
  final ForecastCache _cache;
  final Clock _clock;

  @override
  Future<Either<DataFailure, Forecast>> loadForecast(Place place) =>
      guard(() async {
        final forecastFuture = _remote.fetchForecast(place.point);
        // Air quality is a nice-to-have: its failure must not sink the
        // forecast, so it resolves to null instead of throwing.
        final airFuture = _remote
            .fetchAirNow(place.point)
            .then<Map<String, dynamic>?>((json) => json)
            .catchError((Object _) => null, test: (e) => e is DioException);
        final forecast = await forecastFuture;
        final air = await airFuture;
        final mapped = _map(forecast, air, place);
        await _cache.write(place.key, forecast, air);
        return mapped;
      });

  @override
  Future<Forecast?> readCachedForecast(Place place) async {
    final cached = _cache.read(place.key);
    if (cached == null) return null;
    try {
      return _map(cached.forecast, cached.air, place);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<Either<DataFailure, PastDay>> loadSameDayLastYear(
    Place place,
    DateTime today,
  ) => guard(() async {
    final day = DateTime.utc(today.year - 1, today.month, today.day);
    final iso =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    final json = await _remote.fetchArchiveDay(place.point, iso);
    final daily = json.object('daily');
    return PastDay(
      date: day,
      maxTemperature: daily.list('temperature_2m_max').numberAt(0),
      minTemperature: daily.list('temperature_2m_min').numberAt(0),
    );
  });

  Forecast _map(
    Map<String, dynamic> forecast,
    Map<String, dynamic>? air,
    Place place,
  ) => mapForecast(
    json: forecast,
    airJson: air,
    place: place,
    nowAt: (offset) => placeNow(offset, clock: _clock),
  );
}
