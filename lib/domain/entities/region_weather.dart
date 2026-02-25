import 'package:equatable/equatable.dart';

class RegionWeather extends Equatable {
  final String name;
  final double lat;
  final double lon;
  final double mapX;
  final double mapY;
  final int temp;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final bool isDay;

  const RegionWeather({
    required this.name,
    required this.lat,
    required this.lon,
    required this.mapX,
    required this.mapY,
    required this.temp,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.isDay,
  });

  @override
  List<Object?> get props => [name, temp, weatherCode];
}
