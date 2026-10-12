import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/domain/place.dart';
import '../../core/domain/time_zone_resolver.dart';
import '../../core/format/formats.dart';
import '../../core/l10n/l10n.dart';
import '../../core/notifications/local_notifier.dart';
import '../../features/prayer/domain/prayer_day.dart';
import '../../features/prayer/domain/prayer_times_source.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/weather/domain/entities/forecast.dart';
import '../../features/weather/domain/services/notification_triggers.dart';
import '../../features/prayer/presentation/prayer_labels.dart';

/// Turns forecasts and prayer times into notifications in the user's
/// language. Used by the running app and by the background task, so it
/// takes everything it needs as arguments and holds no UI context.
final class NotificationPlanner {
  const NotificationPlanner(
    this._notifier,
    this._prefs,
    this._prayers,
    this._timeZones,
  );

  final LocalNotifier _notifier;
  final SharedPreferences _prefs;
  final PrayerTimesSource _prayers;
  final TimeZoneResolver _timeZones;

  static const int _dailyId = 1;
  static const Map<NotificationKind, int> _eventIds = <NotificationKind, int>{
    NotificationKind.rainSoon: 10,
    NotificationKind.severeWeather: 11,
    NotificationKind.frost: 12,
    NotificationKind.dust: 13,
  };
  static const int _prayerIdBase = 100;
  static const int _prayerSlots = 12;
  static const int _dailyHour = 7;
  static const String _firedKey = 'v2.fired_notifications';
  static const int _firedMemory = 40;

  Future<void> handleForecast(Forecast forecast, AppSettings settings) async {
    final l10n = lookupAppLocalizations(Locale(settings.languageCode ?? 'uz'));
    final formats = Formats(
      l10n,
      temperatureUnit: settings.temperatureUnit,
      windUnit: settings.windUnit,
      pressureUnit: settings.pressureUnit,
    );
    await _fireEvents(forecast, settings, l10n, formats);
    await _scheduleDaily(forecast, settings, l10n, formats);
  }

  Future<void> _fireEvents(
    Forecast forecast,
    AppSettings settings,
    AppLocalizations l10n,
    Formats formats,
  ) async {
    final fired = _prefs.getStringList(_firedKey) ?? <String>[];
    final city = forecast.place.name;
    for (final trigger in triggersFor(forecast)) {
      if (!settings.isEnabled(trigger.kind) || fired.contains(trigger.key)) {
        continue;
      }
      final message = _messageFor(trigger, forecast, city, l10n, formats);
      if (message == null) continue;
      await _notifier.show(
        id: _eventIds[trigger.kind]!,
        channel: NotificationChannel.alerts,
        title: message.title,
        body: message.body,
      );
      fired.add(trigger.key);
    }
    final recent = fired.length > _firedMemory
        ? fired.sublist(fired.length - _firedMemory)
        : fired;
    await _prefs.setStringList(_firedKey, recent);
  }

  ({String title, String body})? _messageFor(
    NotificationTrigger trigger,
    Forecast forecast,
    String city,
    AppLocalizations l10n,
    Formats formats,
  ) {
    final minutes = trigger.minutes ?? 0;
    return switch (trigger.kind) {
      NotificationKind.rainSoon => (
        title: forecast.current.temperature <= 1
            ? l10n.notifSnowTitle(minutes)
            : l10n.notifRainTitle(minutes),
        body: l10n.notifRainBody(city),
      ),
      NotificationKind.severeWeather => (
        title: l10n.notifStormTitle,
        body: l10n.notifStormBody(
          city,
          formats.time(forecast.fetchedAt.add(Duration(minutes: minutes))),
        ),
      ),
      NotificationKind.frost => (
        title: l10n.notifFrostTitle(formats.temperature(trigger.value ?? 0)),
        body: l10n.notifFrostBody(city),
      ),
      NotificationKind.dust => (
        title: l10n.notifDustTitle,
        body: l10n.notifDustBody(city),
      ),
      NotificationKind.dailySummary || NotificationKind.prayer => null,
    };
  }

  /// One summary at the next 07:00 on the phone's clock, written from the
  /// forecast for that day. Re-planned on every refresh so it stays fresh.
  Future<void> _scheduleDaily(
    Forecast forecast,
    AppSettings settings,
    AppLocalizations l10n,
    Formats formats,
  ) async {
    if (!settings.isEnabled(NotificationKind.dailySummary)) {
      await _notifier.cancelIds(<int>[_dailyId]);
      return;
    }
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, _dailyHour);
    if (!target.isAfter(now)) target = target.add(const Duration(days: 1));
    final day = forecast.daily
        .where(
          (d) =>
              d.date.year == target.year &&
              d.date.month == target.month &&
              d.date.day == target.day,
        )
        .firstOrNull;
    if (day == null) return;
    await _notifier.scheduleAt(
      id: _dailyId,
      channel: NotificationChannel.daily,
      title: l10n.notifDailyTitle(
        forecast.place.name,
        formats.condition(day.condition),
      ),
      body: l10n.notifDailyBody(
        formats.temperature(day.minTemperature),
        formats.temperature(day.maxTemperature),
        formats.percent(day.precipitationProbability),
      ),
      utcInstant: target.toUtc(),
    );
  }

  /// Quiet reminders for today's remaining and tomorrow's prayers.
  Future<void> schedulePrayers(Place place, AppSettings settings) async {
    final slots = <int>[
      for (var i = 0; i < _prayerSlots; i++) _prayerIdBase + i,
    ];
    await _notifier.cancelIds(slots);
    if (!settings.isEnabled(NotificationKind.prayer)) return;

    final l10n = lookupAppLocalizations(Locale(settings.languageCode ?? 'uz'));
    final formats = Formats(l10n);
    final utcNow = DateTime.now().toUtc();
    final offset = _timeZones.offsetSecondsFor(place.timezoneId, utcNow);
    final today = utcNow.add(Duration(seconds: offset));
    var slot = 0;
    for (final date in <DateTime>[today, today.add(const Duration(days: 1))]) {
      final day = _prayers.timesFor(
        point: place.point,
        date: date,
        utcOffsetSeconds: offset,
        method: settings.prayerMethod,
      );
      for (final entry in day.ordered) {
        if (entry.key == Prayer.sunrise || slot >= _prayerSlots) continue;
        await _notifier.scheduleAt(
          id: slots[slot++],
          channel: NotificationChannel.prayer,
          title: l10n.notifPrayerTitle(prayerName(l10n, entry.key)),
          body: l10n.notifPrayerBody(place.name, formats.time(entry.value)),
          utcInstant: entry.value.subtract(Duration(seconds: offset)),
        );
      }
    }
  }
}
