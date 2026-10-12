import 'package:equatable/equatable.dart';

import '../entities/forecast.dart';

/// One sentence of the offline day story. The UI owns the wording in each
/// language; the domain only decides which sentences apply and with what
/// numbers.
enum StoryTopic {
  umbrella,
  snowAndIce,
  storm,
  heat,
  cold,
  layers,
  strongUv,
  wind,
  badAir,
  fogMorning,
  calm,
}

final class StoryLine extends Equatable {
  const StoryLine(this.topic, {this.hour, this.value});

  final StoryTopic topic;

  /// Place-time hour the line refers to (rain peak, gust peak).
  final DateTime? hour;

  /// The number the sentence quotes (°C, km/h, AQI).
  final double? value;

  @override
  List<Object?> get props => <Object?>[topic, hour, value];
}

final class DayStory extends Equatable {
  const DayStory({required this.lines, this.bestHour});

  /// At most three, most important first.
  final List<StoryLine> lines;

  /// The most comfortable daylight hour to be outside, if any is decent.
  final DateTime? bestHour;

  @override
  List<Object?> get props => <Object?>[lines, bestHour];
}

const int _maxLines = 3;

DayStory composeDayStory(Forecast forecast) {
  final today = forecast.today;
  final hours = forecast.hourly.take(18).toList();
  final lines = <StoryLine>[];

  final storm = hours.where((h) => h.condition.isStormy).firstOrNull;
  if (storm != null) lines.add(StoryLine(StoryTopic.storm, hour: storm.time));

  final wettest = _maxBy(hours, (h) => h.precipitationProbability);
  final snowy = hours.any((h) => h.condition.isSnowy);
  final freezingWet =
      (today?.minTemperature ?? 99) <= 0 &&
      hours.any((h) => h.condition.isWet || h.condition.isSnowy);
  if (snowy || freezingWet) {
    lines.add(const StoryLine(StoryTopic.snowAndIce));
  } else if (wettest != null && wettest.precipitationProbability >= 50) {
    lines.add(
      StoryLine(
        StoryTopic.umbrella,
        hour: wettest.time,
        value: wettest.precipitationProbability,
      ),
    );
  }

  final aqi = forecast.air?.usAqi ?? 0;
  if (aqi >= 150) lines.add(StoryLine(StoryTopic.badAir, value: aqi));

  final gustiest = _maxBy(hours, (h) => h.windGusts);
  if (gustiest != null && gustiest.windGusts >= 50) {
    lines.add(
      StoryLine(
        StoryTopic.wind,
        hour: gustiest.time,
        value: gustiest.windGusts,
      ),
    );
  }

  final max = today?.maxTemperature ?? forecast.current.temperature;
  final min = today?.minTemperature ?? forecast.current.temperature;
  if (max >= 33) {
    lines.add(StoryLine(StoryTopic.heat, value: max));
  } else if (max <= 5) {
    lines.add(StoryLine(StoryTopic.cold, value: min));
  } else if (max - min >= 12) {
    lines.add(StoryLine(StoryTopic.layers, value: min));
  }

  final uv = today?.uvIndexMax ?? 0;
  if (uv >= 7) lines.add(StoryLine(StoryTopic.strongUv, value: uv));

  final foggyMorning = hours.any(
    (h) => h.time.hour <= 10 && h.visibility > 0 && h.visibility < 1000,
  );
  if (foggyMorning) lines.add(const StoryLine(StoryTopic.fogMorning));

  if (lines.isEmpty) lines.add(const StoryLine(StoryTopic.calm));
  return DayStory(
    lines: lines.take(_maxLines).toList(growable: false),
    bestHour: _bestHour(hours),
  );
}

/// Daylight hour (07–21) with the least rain and the temperature closest to
/// a comfortable 22 °C.
DateTime? _bestHour(List<HourlyWeather> hours) {
  final candidates = hours.where(
    (h) =>
        h.isDay &&
        h.time.hour >= 7 &&
        h.time.hour <= 21 &&
        h.precipitationProbability < 40 &&
        !h.condition.isStormy,
  );
  final best = _minBy(
    candidates,
    (h) => (h.apparentTemperature - 22).abs() + h.precipitationProbability / 5,
  );
  return best?.time;
}

T? _maxBy<T>(Iterable<T> items, double Function(T) score) {
  T? best;
  for (final item in items) {
    if (best == null || score(item) > score(best)) best = item;
  }
  return best;
}

T? _minBy<T>(Iterable<T> items, double Function(T) score) {
  T? best;
  for (final item in items) {
    if (best == null || score(item) < score(best)) best = item;
  }
  return best;
}
