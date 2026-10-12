import 'dart:ui';

import 'package:home_widget/home_widget.dart';

import '../../core/format/formats.dart';
import '../../core/l10n/l10n.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/services/nowcast_outlook.dart';

/// Pushes the latest forecast to the home-screen widget. Keys are read by
/// `OsmonWidgetProvider.kt`; keep both sides in sync.
final class HomeWidgetSync {
  const HomeWidgetSync();

  static const String androidProvider = 'OsmonWidgetProvider';
  static const String iosKind = 'OsmonWidget';

  Future<void> publish(Forecast forecast, AppSettings settings) async {
    final l10n = lookupAppLocalizations(Locale(settings.languageCode ?? 'uz'));
    final formats = Formats(
      l10n,
      temperatureUnit: settings.temperatureUnit,
      windUnit: settings.windUnit,
    );
    final today = forecast.today;
    final outlook = summarizeNowcast(
      forecast.nowcast,
      now: forecast.fetchedAt,
      temperature: forecast.current.temperature,
    );
    final data = <String, String>{
      'osmon_city': forecast.place.name,
      'osmon_temp': formats.temperature(forecast.current.temperature),
      'osmon_condition': formats.condition(forecast.current.condition),
      'osmon_range': today == null
          ? ''
          : '${formats.temperature(today.minTemperature)} … '
                '${formats.temperature(today.maxTemperature)}',
      'osmon_outlook': switch (outlook) {
        PrecipitationAhead(:final startsIn) => l10n.widgetRainIn(
          startsIn.inMinutes.toString(),
        ),
        PrecipitationNow() => l10n.widgetRainNow,
        DryOutlook() => l10n.widgetDry,
      },
      'osmon_updated': l10n.widgetUpdated(formats.time(forecast.fetchedAt)),
      'osmon_scene': forecast.current.isDay ? 'day' : 'night',
    };
    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }
    await HomeWidget.updateWidget(
      androidName: androidProvider,
      iOSName: iosKind,
    );
  }
}
