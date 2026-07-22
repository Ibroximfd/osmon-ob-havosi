import '../models/weather_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import 'package:logger/logger.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather(double lat, double lon, String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient apiClient;
  final _log = Logger();

  WeatherRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WeatherModel> getWeather(
    double lat,
    double lon,
    String cityName,
  ) async {
    _log.i('WeatherAPI — so\'rov: $cityName [$lat, $lon]');

    final weatherFuture = apiClient.getWeather({
      'latitude': lat,
      'longitude': lon,
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,pressure_msl',
      'hourly': 'temperature_2m,weather_code',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
    });

    final aqiFuture = apiClient.getAirQuality({
      'latitude': lat,
      'longitude': lon,
      'current': 'us_aqi,european_aqi',
      'timezone': 'auto',
    });

    try {
      final results = await Future.wait([weatherFuture, aqiFuture]);
      final weatherResponse = results[0];
      final aqiResponse = results[1];

      _log.i('WeatherAPI javob — status: ${weatherResponse.statusCode}');
      _log.d('WeatherAPI current: ${weatherResponse.data['current']}');
      _log.i('AQI API javob — status: ${aqiResponse.statusCode}');
      _log.d('AQI current: ${aqiResponse.data['current']}');

      final usAqi = (aqiResponse.data['current']['us_aqi'] as num?)?.round();
      final euAqi = (aqiResponse.data['current']['european_aqi'] as num?)
          ?.round();
      // US AQI saytlardagi ko'rsatkichlarga mos keladi (IQAir, AirVisual va h.k.)
      final aqiValue = usAqi ?? euAqi ?? 0;

      _log.i('AQI — US: $usAqi, EU: $euAqi, ishlatiladigan: $aqiValue');

      return WeatherModel.fromJson(weatherResponse.data, cityName, aqiValue);
    } catch (e, st) {
      _log.e('WeatherAPI xatolik', error: e, stackTrace: st);
      throw ServerException();
    }
  }
}
