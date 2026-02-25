import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state_event.dart';
import '../../../../domain/usecases/get_weather_usecase.dart';
import '../../../../data/datasources/gemini_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetWeatherUseCase getWeather;
  final GeminiService geminiService;

  HomeBloc({required this.getWeather, required this.geminiService})
    : super(HomeInitial()) {
    on<LoadWeatherEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final weather = await getWeather(
          GetWeatherParams(
            lat: event.city.lat,
            lon: event.city.lon,
            cityName: event.city.name,
          ),
        );

        // Fetch AI and agriculture advice in parallel
        final results = await Future.wait([
          geminiService.getAIWeatherAdvice(weather),
          geminiService.getAgricultureAdvice(weather),
        ]);

        emit(
          HomeLoaded(
            weather: weather,
            advice: results[0],
            agricultureAdvice: results[1],
            currentCity: event.city,
          ),
        );
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
