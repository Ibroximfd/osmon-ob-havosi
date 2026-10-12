import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/domain/place.dart';
import '../../../core/domain/place_time.dart';
import '../../../core/domain/weather_condition.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/alerts_repository.dart';
import '../domain/weather_alert.dart';

final class OpenMeteoAlertsRepository implements AlertsRepository {
  const OpenMeteoAlertsRepository(this._http);

  final Dio _http;

  static const int _forecastDays = 3;

  @override
  Future<Either<DataFailure, Map<Place, List<RegionDay>>>> loadRegionDays(
    List<Place> places,
  ) => guard(() async {
    final coordinates = <String, String>{
      'latitude': places
          .map((p) => p.point.latitude.toStringAsFixed(4))
          .join(','),
      'longitude': places
          .map((p) => p.point.longitude.toStringAsFixed(4))
          .join(','),
    };
    final forecastFuture = _http.get<Object>(
      ApiEndpoints.forecast,
      queryParameters: <String, Object>{
        ...coordinates,
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,'
            'precipitation_sum,snowfall_sum,wind_gusts_10m_max',
        'forecast_days': _forecastDays,
        'timezone': 'auto',
      },
    );
    final dustFuture = _http
        .get<Object>(
          ApiEndpoints.airQuality,
          queryParameters: <String, Object>{
            ...coordinates,
            'hourly': 'dust',
            'forecast_days': _forecastDays,
            'timezone': 'auto',
          },
        )
        .then<Object?>((response) => response.data)
        .catchError((Object _) => null, test: (e) => e is DioException);

    final forecasts = _locations((await forecastFuture).data);
    final dust = _locations(await dustFuture);
    return <Place, List<RegionDay>>{
      for (var i = 0; i < places.length && i < forecasts.length; i++)
        places[i]: _days(
          forecasts[i].object('daily'),
          i < dust.length ? _dailyDustMax(dust[i]) : const <DateTime, double>{},
        ),
    };
  });

  static List<Map<String, dynamic>> _locations(Object? data) => data is List
      ? data.whereType<Map<String, dynamic>>().toList()
      : <Map<String, dynamic>>[if (data is Map<String, dynamic>) data];

  static Map<DateTime, double> _dailyDustMax(Map<String, dynamic> json) {
    final hourly = json.objectOrNull('hourly');
    if (hourly == null) return const <DateTime, double>{};
    final times = hourly.list('time');
    final values = hourly.list('dust');
    final max = <DateTime, double>{};
    for (var i = 0; i < times.length; i++) {
      final value = values.numberOrNullAt(i);
      if (value == null) continue;
      final day = parsePlaceTime(times.textAt(i)).dateOnly;
      if (value > (max[day] ?? 0)) max[day] = value;
    }
    return max;
  }

  static List<RegionDay> _days(
    Map<String, dynamic> d,
    Map<DateTime, double> dust,
  ) {
    final dates = d.list('time');
    return <RegionDay>[
      for (var i = 0; i < dates.length; i++)
        RegionDay(
          date: parsePlaceTime(dates.textAt(i)),
          condition: WeatherCondition.fromWmo(
            (d.list('weather_code').numberOrNullAt(i) ?? 0).round(),
          ),
          maxTemperature: d.list('temperature_2m_max').numberOrNullAt(i) ?? 0,
          minTemperature: d.list('temperature_2m_min').numberOrNullAt(i) ?? 0,
          precipitationSum: d.list('precipitation_sum').numberOrNullAt(i) ?? 0,
          snowfallSum: d.list('snowfall_sum').numberOrNullAt(i) ?? 0,
          windGustsMax: d.list('wind_gusts_10m_max').numberOrNullAt(i) ?? 0,
          dustMax: dust[parsePlaceTime(dates.textAt(i)).dateOnly],
        ),
    ];
  }
}
