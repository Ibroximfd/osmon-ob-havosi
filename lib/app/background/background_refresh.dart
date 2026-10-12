import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';

import '../../core/network/http_client.dart';
import '../../core/notifications/local_notifier.dart';
import '../../core/time/tz_time_zone_resolver.dart';
import '../../features/location/data/device_location_repository.dart';
import '../../features/prayer/data/adhan_prayer_times_source.dart';
import '../../features/settings/data/prefs_settings_repository.dart';
import '../../features/weather/data/datasources/forecast_cache.dart';
import '../../features/weather/data/datasources/forecast_remote_source.dart';
import '../../features/weather/data/open_meteo_weather_repository.dart';
import '../services/home_widget_sync.dart';
import '../services/notification_planner.dart';

/// Hourly refresh while the app is closed: rain-soon and severe-weather
/// alerts, tomorrow's 07:00 summary, prayer reminders and the home widget.
/// Android runs it reliably; iOS treats it as a best-effort hint.
abstract final class BackgroundRefresh {
  static const String _uniqueName = 'uz.osmon.refresh';
  static const String _taskName = 'uz.osmon.refresh';
  static const Duration _frequency = Duration(hours: 1);

  static Future<void> register() async {
    await Workmanager().initialize(backgroundDispatcher);
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _taskName,
      frequency: _frequency,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }
}

/// Runs in a fresh isolate with no service locator, so it builds the few
/// objects it needs by hand.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    tz_data.initializeTimeZones();

    final prefs = await SharedPreferences.getInstance();
    final settings = PrefsSettingsRepository(prefs).current;
    final place = DeviceLocationRepository(prefs).selectedPlace;
    if (place == null || !settings.onboardingDone) return true;

    final http = createHttpClient();
    final weather = OpenMeteoWeatherRepository(
      ForecastRemoteSource(http),
      ForecastCache(prefs),
    );
    final forecast = (await weather.loadForecast(
      place,
    )).fold((_) => null, (value) => value);
    final planner = NotificationPlanner(
      LocalNotifier(),
      prefs,
      const AdhanPrayerTimesSource(),
      const TzTimeZoneResolver(),
    );
    await planner.schedulePrayers(place, settings);
    if (forecast == null) return true;
    await planner.handleForecast(forecast, settings);
    await const HomeWidgetSync().publish(forecast, settings);
    return true;
  });
}
