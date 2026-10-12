import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/units.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Settings in SharedPreferences. Also migrates the 1.x keys once, so the
/// people who already use the app keep their units and skip onboarding.
final class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository(this._prefs) : _current = _read(_prefs);

  final SharedPreferences _prefs;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();
  AppSettings _current;

  static const String _language = 'v2.language';
  static const String _temperature = 'v2.temperature_unit';
  static const String _wind = 'v2.wind_unit';
  static const String _pressure = 'v2.pressure_unit';
  static const String _liveBackground = 'v2.live_background';
  static const String _batterySaver = 'v2.battery_saver';
  static const String _reduceMotion = 'v2.reduce_motion';
  static const String _prayerMethod = 'v2.prayer_method';
  static const String _notifications = 'v2.notifications';
  static const String _onboardingDone = 'v2.onboarding_done';

  // 1.x keys.
  static const String _legacyTemperature = 'settings_temp_unit';
  static const String _legacyWind = 'settings_wind_unit';
  static const String _legacyShowOnboarding = 'show_onboarding';

  @override
  AppSettings get current => _current;

  @override
  Stream<AppSettings> watch() => _changes.stream;

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
    _changes.add(settings);
    final language = settings.languageCode;
    await Future.wait(<Future<bool>>[
      if (language != null) _prefs.setString(_language, language),
      _prefs.setString(_temperature, settings.temperatureUnit.name),
      _prefs.setString(_wind, settings.windUnit.name),
      _prefs.setString(_pressure, settings.pressureUnit.name),
      _prefs.setBool(_liveBackground, settings.liveBackground),
      _prefs.setBool(_batterySaver, settings.batterySaver),
      _prefs.setBool(_reduceMotion, settings.reduceMotion),
      _prefs.setString(_prayerMethod, settings.prayerMethod.name),
      _prefs.setStringList(
        _notifications,
        settings.notifications.map((kind) => kind.name).toList(),
      ),
      _prefs.setBool(_onboardingDone, settings.onboardingDone),
    ]);
  }

  static AppSettings _read(SharedPreferences prefs) {
    const defaults = AppSettings();
    final legacyOnboardingDone = prefs.getBool(_legacyShowOnboarding) == false;
    final storedNotifications = prefs.getStringList(_notifications);
    return AppSettings(
      languageCode: prefs.getString(_language),
      temperatureUnit:
          _byName(TemperatureUnit.values, prefs.getString(_temperature)) ??
          (prefs.getString(_legacyTemperature) == 'F'
              ? TemperatureUnit.fahrenheit
              : defaults.temperatureUnit),
      windUnit:
          _byName(WindUnit.values, prefs.getString(_wind)) ??
          (prefs.getString(_legacyWind) == 'm/s'
              ? WindUnit.metresPerSecond
              : defaults.windUnit),
      pressureUnit:
          _byName(PressureUnit.values, prefs.getString(_pressure)) ??
          defaults.pressureUnit,
      liveBackground: prefs.getBool(_liveBackground) ?? defaults.liveBackground,
      batterySaver: prefs.getBool(_batterySaver) ?? defaults.batterySaver,
      reduceMotion: prefs.getBool(_reduceMotion) ?? defaults.reduceMotion,
      prayerMethod:
          _byName(PrayerMethod.values, prefs.getString(_prayerMethod)) ??
          defaults.prayerMethod,
      notifications: storedNotifications == null
          ? defaults.notifications
          : storedNotifications
                .map((name) => _byName(NotificationKind.values, name))
                .whereType<NotificationKind>()
                .toSet(),
      onboardingDone: prefs.getBool(_onboardingDone) ?? legacyOnboardingDone,
    );
  }

  static T? _byName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
