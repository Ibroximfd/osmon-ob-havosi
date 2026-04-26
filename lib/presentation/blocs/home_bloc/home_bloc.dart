import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state_event.dart';
import '../../../../domain/usecases/get_weather_usecase.dart';
import '../../../../data/datasources/local_advice_service.dart';
import '../../../../data/datasources/gemini_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetWeatherUseCase getWeather;
  final GeminiService geminiService;
  final _local = LocalAdviceService();

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

        // Mahalliy maslahat darhol ko'rsatiladi
        emit(HomeLoaded(
          weather: weather,
          advice: _local.getAIWeatherAdvice(weather),
          agricultureAdvice: _local.getAgricultureAdvice(weather),
          currentCity: event.city,
          isAdviceLoading: false,
        ));

        // Gemini kesh dan yoki API dan yaxshilangan maslahat olishga harakat
        final cached = await geminiService.getCachedAdvice(weather);
        if (cached != null && state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(
            advice: cached.advice,
            agricultureAdvice: cached.agriculture,
          ));
          return;
        }

        // Gemini ni await qilamiz — emitter handler ichida tugashi kerak
        final result = await geminiService.fetchAdviceInBackground(weather);
        if (result != null && !emit.isDone && state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(
            advice: result.advice,
            agricultureAdvice: result.agriculture,
          ));
        }
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
