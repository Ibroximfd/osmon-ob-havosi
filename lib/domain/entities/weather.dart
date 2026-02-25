import 'package:equatable/equatable.dart';

class HourlyForecast extends Equatable {
  final String time;
  final int temp;
  final int code;

  const HourlyForecast({
    required this.time,
    required this.temp,
    required this.code,
  });

  @override
  List<Object?> get props => [time, temp, code];
}

class DailyForecast extends Equatable {
  final String day;
  final int min;
  final int max;
  final int code;

  const DailyForecast({
    required this.day,
    required this.min,
    required this.max,
    required this.code,
  });

  @override
  List<Object?> get props => [day, min, max, code];
}

class Weather extends Equatable {
  final int temp;
  final String condition;
  final String city;
  final int feelsLike;
  final int humidity;
  final double windSpeed;
  final int aqi;
  final int pressure;
  final bool isDay;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const Weather({
    required this.temp,
    required this.condition,
    required this.city,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.aqi,
    required this.pressure,
    required this.isDay,
    required this.hourly,
    required this.daily,
  });

  @override
  List<Object?> get props => [
    temp,
    condition,
    city,
    feelsLike,
    humidity,
    windSpeed,
    aqi,
    pressure,
    isDay,
    hourly,
    daily,
  ];
}
