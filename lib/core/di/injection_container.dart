import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/gemini_service.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import '../../data/datasources/map_data_source.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../../presentation/blocs/home_bloc/home_bloc.dart';
import '../../presentation/blocs/map_bloc/map_bloc.dart';
import '../../presentation/blocs/settings_cubit/settings_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Network
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => GeminiService());
  sl.registerLazySingleton(() => MapDataSource());

  // Data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWeatherUseCase(sl()));

  // Blocs
  sl.registerFactory(() => HomeBloc(getWeather: sl(), geminiService: sl()));
  sl.registerFactory(() => MapBloc(dataSource: sl()));
  sl.registerLazySingleton(() => SettingsCubit(sl<SharedPreferences>()));
}
