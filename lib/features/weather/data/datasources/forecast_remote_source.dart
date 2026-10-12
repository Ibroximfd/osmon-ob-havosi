import 'package:dio/dio.dart';

import '../../../../core/domain/geo_point.dart';
import '../../../../core/network/api_endpoints.dart';

/// Raw Open-Meteo calls. Throws Dio exceptions; the repository maps them.
final class ForecastRemoteSource {
  const ForecastRemoteSource(this._http);

  final Dio _http;

  static const String _current =
      'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
      'precipitation,weather_code,cloud_cover,pressure_msl,wind_speed_10m,'
      'wind_direction_10m,wind_gusts_10m,visibility,uv_index,dew_point_2m';
  static const String _hourly =
      'temperature_2m,apparent_temperature,relative_humidity_2m,'
      'precipitation_probability,precipitation,weather_code,cloud_cover,'
      'visibility,wind_speed_10m,wind_gusts_10m,uv_index,is_day,pressure_msl';
  static const String _daily =
      'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,'
      'uv_index_max,precipitation_sum,precipitation_probability_max,'
      'wind_speed_10m_max,wind_gusts_10m_max,snowfall_sum';

  Future<Map<String, dynamic>> fetchForecast(GeoPoint point) async {
    final response = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.forecast,
      queryParameters: <String, Object>{
        'latitude': point.latitude,
        'longitude': point.longitude,
        'current': _current,
        'hourly': _hourly,
        'daily': _daily,
        'minutely_15': 'precipitation',
        'forecast_minutely_15': 12,
        'past_hours': 24,
        'forecast_days': 10,
        'timezone': 'auto',
      },
    );
    return response.data ?? (throw const FormatException('empty forecast'));
  }

  Future<Map<String, dynamic>> fetchAirNow(GeoPoint point) async {
    final response = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.airQuality,
      queryParameters: <String, Object>{
        'latitude': point.latitude,
        'longitude': point.longitude,
        'current': 'us_aqi,pm10,pm2_5,dust',
        'timezone': 'auto',
      },
    );
    return response.data ?? (throw const FormatException('empty air'));
  }

  Future<Map<String, dynamic>> fetchArchiveDay(
    GeoPoint point,
    String isoDate,
  ) async {
    final response = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.archive,
      queryParameters: <String, Object>{
        'latitude': point.latitude,
        'longitude': point.longitude,
        'start_date': isoDate,
        'end_date': isoDate,
        'daily': 'temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
      },
    );
    return response.data ?? (throw const FormatException('empty archive'));
  }
}
