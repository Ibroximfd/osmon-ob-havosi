import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/domain/time_zone_resolver.dart';
import '../../core/network/http_client.dart';
import '../../core/notifications/local_notifier.dart';
import '../../core/time/tz_time_zone_resolver.dart';
import '../../features/ai/data/gal_gallery_saver.dart';
import '../../features/ai/data/gemini_ai_repository.dart';
import '../../features/ai/domain/ai_repository.dart';
import '../../features/ai/domain/gallery_saver.dart';
import '../../features/ai/presentation/bloc/chat_bloc.dart';
import '../../features/ai/presentation/bloc/photo_bloc.dart';
import '../../features/alerts/data/open_meteo_alerts_repository.dart';
import '../../features/alerts/domain/alerts_repository.dart';
import '../../features/alerts/presentation/bloc/alerts_bloc.dart';
import '../../features/favorites/data/prefs_favorites_repository.dart';
import '../../features/favorites/domain/favorites_repository.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/field/data/open_meteo_field_repository.dart';
import '../../features/field/domain/field_repository.dart';
import '../../features/field/presentation/bloc/field_bloc.dart';
import '../../features/health/data/open_meteo_air_quality_repository.dart';
import '../../features/health/domain/air_quality_repository.dart';
import '../../features/health/presentation/bloc/health_bloc.dart';
import '../../features/location/data/device_location_repository.dart';
import '../../features/location/data/open_meteo_place_search_repository.dart';
import '../../features/location/domain/location_repository.dart';
import '../../features/location/domain/place_search_repository.dart';
import '../../features/location/presentation/bloc/place_search_bloc.dart';
import '../../features/map/data/open_meteo_map_repository.dart';
import '../../features/map/domain/map_repository.dart';
import '../../features/map/domain/weather_grid.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/prayer/data/adhan_prayer_times_source.dart';
import '../../features/prayer/domain/prayer_times_source.dart';
import '../../features/prayer/presentation/bloc/prayer_bloc.dart';
import '../../features/route/data/osrm_route_repository.dart';
import '../../features/route/domain/route_repository.dart';
import '../../features/route/presentation/bloc/route_bloc.dart';
import '../../features/settings/data/prefs_settings_repository.dart';
import '../../features/settings/domain/notification_permissions.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/weather/data/datasources/forecast_cache.dart';
import '../../features/weather/data/datasources/forecast_remote_source.dart';
import '../../features/weather/data/open_meteo_weather_repository.dart';
import '../../features/weather/domain/weather_repository.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../services/home_widget_sync.dart';
import '../services/notification_planner.dart';

final GetIt sl = GetIt.instance;

/// The composition root. Interfaces are registered against their
/// implementations here and nowhere else.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  final notifier = LocalNotifier();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<Dio>(createHttpClient)
    ..registerSingleton<LocalNotifier>(notifier)
    ..registerSingleton<NotificationPermissions>(notifier)
    ..registerLazySingleton<TimeZoneResolver>(TzTimeZoneResolver.new)
    // Repositories
    ..registerLazySingleton<SettingsRepository>(
      () => PrefsSettingsRepository(sl()),
    )
    ..registerLazySingleton<LocationRepository>(
      () => DeviceLocationRepository(sl()),
    )
    ..registerLazySingleton<PlaceSearchRepository>(
      () => OpenMeteoPlaceSearchRepository(sl()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => PrefsFavoritesRepository(sl()),
    )
    ..registerLazySingleton<WeatherRepository>(
      () => OpenMeteoWeatherRepository(
        ForecastRemoteSource(sl()),
        ForecastCache(sl()),
      ),
    )
    ..registerLazySingleton<AiRepository>(() => GeminiAiRepository(sl(), sl()))
    ..registerLazySingleton<GallerySaver>(GalGallerySaver.new)
    ..registerLazySingleton<AirQualityRepository>(
      () => OpenMeteoAirQualityRepository(sl()),
    )
    ..registerLazySingleton<PrayerTimesSource>(AdhanPrayerTimesSource.new)
    ..registerLazySingleton<FieldRepository>(
      () => OpenMeteoFieldRepository(sl(), sl()),
    )
    ..registerLazySingleton<RouteRepository>(
      () => OsrmRouteRepository(sl(), sl()),
    )
    ..registerLazySingleton<AlertsRepository>(
      () => OpenMeteoAlertsRepository(sl()),
    )
    ..registerLazySingleton<MapRepository>(
      () => OpenMeteoMapRepository(sl(), sl()),
    )
    // App services
    ..registerLazySingleton<NotificationPlanner>(
      () => NotificationPlanner(sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<HomeWidgetSync>(HomeWidgetSync.new)
    // Session-wide Blocs: settings, the current forecast and favourites are
    // read by many screens at once and must not reset on navigation.
    ..registerLazySingleton<SettingsBloc>(() => SettingsBloc(sl(), sl()))
    ..registerLazySingleton<WeatherBloc>(
      () =>
          WeatherBloc(weather: sl(), location: sl(), settings: sl(), ai: sl()),
    )
    ..registerLazySingleton<FavoritesBloc>(() => FavoritesBloc(sl()))
    // Screen Blocs: a fresh one per route.
    ..registerFactory<OnboardingBloc>(
      () => OnboardingBloc(
        settings: sl(),
        location: sl(),
        notifications: sl(),
        deviceLanguageCode: PlatformDispatcher.instance.locale.languageCode,
      ),
    )
    ..registerFactory<PlaceSearchBloc>(() => PlaceSearchBloc(sl(), sl()))
    ..registerFactory<HealthBloc>(() => HealthBloc(sl(), sl()))
    ..registerFactory<PrayerBloc>(
      () => PrayerBloc(
        location: sl(),
        settings: sl(),
        times: sl(),
        timeZones: sl(),
      ),
    )
    ..registerFactory<FieldBloc>(() => FieldBloc(sl(), sl()))
    ..registerFactory<RouteBloc>(
      () => RouteBloc(routes: sl(), location: sl(), settings: sl()),
    )
    ..registerFactory<AlertsBloc>(() => AlertsBloc(sl(), sl()))
    ..registerFactoryParam<MapBloc, MapLayer, void>(
      (layer, _) =>
          MapBloc(repository: sl(), location: sl(), initialLayer: layer),
    )
    ..registerFactory<ChatBloc>(() => ChatBloc(sl(), sl()))
    ..registerFactory<PhotoBloc>(() => PhotoBloc(sl(), sl(), sl()));
}
