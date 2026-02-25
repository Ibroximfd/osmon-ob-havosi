import 'package:equatable/equatable.dart';
import '../../../../domain/entities/city.dart';
import '../../../../domain/entities/weather.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Weather weather;
  final String advice;
  final String agricultureAdvice;
  final City currentCity;

  const HomeLoaded({
    required this.weather,
    required this.advice,
    required this.agricultureAdvice,
    required this.currentCity,
  });

  @override
  List<Object> get props => [weather, advice, agricultureAdvice, currentCity];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadWeatherEvent extends HomeEvent {
  final City city;
  const LoadWeatherEvent(this.city);

  @override
  List<Object> get props => [city];
}
