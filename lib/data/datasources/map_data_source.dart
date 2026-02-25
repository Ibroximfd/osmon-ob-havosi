import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/region_weather.dart';
import '../../core/constants/api_constants.dart';

class MapDataSource {
  final Dio _dio;
  final _log = Logger();

  MapDataSource()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.weatherBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<List<RegionWeather>> getAllRegionsWeather() async {
    final regions = RegionCity.allRegions;
    _log.i(
      'Xarita: ${regions.length} ta viloyat uchun API so\'rovlari boshlanmoqda...',
    );

    final futures = regions.map((region) => _fetchRegion(region));

    final results = await Future.wait(futures, eagerError: false);

    final valid = results.whereType<RegionWeather>().toList();
    _log.i(
      'Xarita: ${valid.length}/${regions.length} ta viloyat muvaffaqiyatli yuklandi',
    );

    return valid;
  }

  Future<RegionWeather?> _fetchRegion(RegionCity region) async {
    try {
      final response = await _dio.get(
        ApiConstants.forecastPath,
        queryParameters: {
          'latitude': region.lat,
          'longitude': region.lon,
          'current':
              'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day',
          'timezone': ApiConstants.defaultTimezone,
        },
      );

      final current = response.data['current'];
      final temp = (current['temperature_2m'] as num).round();
      _log.d('${region.name}: $temp°C');

      return RegionWeather(
        name: region.name,
        lat: region.lat,
        lon: region.lon,
        mapX: region.mapX,
        mapY: region.mapY,
        temp: temp,
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).round(),
        weatherCode: current['weather_code'] as int,
        isDay: current['is_day'] == 1,
      );
    } catch (e) {
      _log.e('${region.name} uchun xatolik', error: e);
      return null;
    }
  }
}
