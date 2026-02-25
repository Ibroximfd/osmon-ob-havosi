import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';
import '../../core/errors/exceptions.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Weather> getWeather(double lat, double lon, String cityName) async {
    try {
      final remoteWeather = await remoteDataSource.getWeather(
        lat,
        lon,
        cityName,
      );
      return remoteWeather;
    } on ServerException {
      throw Exception('Server error occurred');
    }
  }
}
