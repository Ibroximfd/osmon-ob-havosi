import 'package:equatable/equatable.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';
import '../../core/usecases/usecase.dart';

class GetWeatherUseCase implements UseCase<Weather, GetWeatherParams> {
  final WeatherRepository repository;

  GetWeatherUseCase(this.repository);

  @override
  Future<Weather> call(GetWeatherParams params) async {
    return await repository.getWeather(params.lat, params.lon, params.cityName);
  }
}

class GetWeatherParams extends Equatable {
  final double lat;
  final double lon;
  final String cityName;

  const GetWeatherParams({
    required this.lat,
    required this.lon,
    required this.cityName,
  });

  @override
  List<Object?> get props => [lat, lon, cityName];
}
