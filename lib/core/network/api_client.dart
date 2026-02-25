import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _weatherDio;
  final Dio _aqiDio;

  ApiClient()
    : _weatherDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.weatherBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ),
      _aqiDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.airQualityBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<Response> getWeather(Map<String, dynamic> queryParams) {
    return _weatherDio.get(
      ApiConstants.forecastPath,
      queryParameters: queryParams,
    );
  }

  Future<Response> getAirQuality(Map<String, dynamic> queryParams) {
    return _aqiDio.get(
      ApiConstants.airQualityPath,
      queryParameters: queryParams,
    );
  }
}
