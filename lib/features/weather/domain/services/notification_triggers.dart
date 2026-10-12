import 'package:equatable/equatable.dart';

import '../../../settings/domain/app_settings.dart';
import '../entities/forecast.dart';
import 'nowcast_outlook.dart';

/// An event worth interrupting someone for. [key] de-duplicates: the same
/// rain shower must not notify twice across refreshes.
final class NotificationTrigger extends Equatable {
  const NotificationTrigger({
    required this.kind,
    required this.key,
    this.minutes,
    this.value,
  });

  final NotificationKind kind;
  final String key;

  /// Minutes until the event, for "rain in 20 minutes".
  final int? minutes;

  /// The number quoted in the message (°C for frost, µg/m³ for dust).
  final double? value;

  @override
  List<Object?> get props => <Object?>[kind, key, minutes, value];
}

const int _rainLeadMinutes = 45;
const int _stormLookaheadHours = 12;
const int _frostEveningStart = 15;
const int _frostEveningEnd = 22;

String _day(DateTime t) => '${t.year}${t.month}${t.day}';

List<NotificationTrigger> triggersFor(Forecast forecast) {
  final now = forecast.fetchedAt;
  final triggers = <NotificationTrigger>[];

  final outlook = summarizeNowcast(
    forecast.nowcast,
    now: now,
    temperature: forecast.current.temperature,
  );
  if (outlook is PrecipitationAhead &&
      outlook.startsIn.inMinutes <= _rainLeadMinutes) {
    final start = now.add(outlook.startsIn);
    triggers.add(
      NotificationTrigger(
        kind: NotificationKind.rainSoon,
        key: 'rain-${_day(start)}-${start.hour}',
        minutes: outlook.startsIn.inMinutes,
      ),
    );
  }

  final storm = forecast.hourly
      .take(_stormLookaheadHours)
      .where((h) => h.condition.isStormy)
      .firstOrNull;
  if (storm != null) {
    triggers.add(
      NotificationTrigger(
        kind: NotificationKind.severeWeather,
        key: 'storm-${_day(storm.time)}',
        minutes: storm.time.difference(now).inMinutes,
      ),
    );
  }

  final isEvening =
      now.hour >= _frostEveningStart && now.hour <= _frostEveningEnd;
  final tonight = forecast.daily.length > 1 ? forecast.daily[1] : null;
  if (isEvening && tonight != null && tonight.minTemperature <= 0) {
    triggers.add(
      NotificationTrigger(
        kind: NotificationKind.frost,
        key: 'frost-${_day(tonight.date)}',
        value: tonight.minTemperature,
      ),
    );
  }

  final dust = forecast.air?.dust ?? 0;
  final pm10 = forecast.air?.pm10 ?? 0;
  if (dust >= 150 || pm10 >= 250) {
    triggers.add(
      NotificationTrigger(
        kind: NotificationKind.dust,
        key: 'dust-${_day(now)}',
        value: dust >= 150 ? dust : pm10,
      ),
    );
  }
  return triggers;
}
