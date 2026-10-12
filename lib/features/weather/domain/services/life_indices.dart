import 'package:equatable/equatable.dart';

import '../entities/forecast.dart';

enum LifeActivity { laundry, carWash, running, cycling, walking, stargazing }

enum IndexRating { good, fair, poor }

/// Why the rating is what it is — each maps to one localized sentence.
enum IndexReason {
  rainExpected,
  tooHumid,
  tooCold,
  tooHot,
  goodDrying,
  dryDaysAhead,
  dusty,
  freezing,
  badAir,
  stormy,
  windy,
  wet,
  pleasant,
  clearSky,
  someClouds,
  cloudy,
}

final class LifeIndex extends Equatable {
  const LifeIndex(this.activity, this.rating, this.reason);

  final LifeActivity activity;
  final IndexRating rating;
  final IndexReason reason;

  @override
  List<Object?> get props => <Object?>[activity, rating, reason];
}

/// Six one-line answers people actually ask a weather app. Pure rules over
/// the forecast so they work offline and are unit-testable.
List<LifeIndex> lifeIndicesFor(Forecast forecast) => <LifeIndex>[
  _laundry(forecast),
  _carWash(forecast),
  _exercise(forecast, LifeActivity.running, windyAt: 30, gustyAt: 60),
  _exercise(forecast, LifeActivity.cycling, windyAt: 20, gustyAt: 45),
  _walking(forecast),
  _stargazing(forecast),
];

Iterable<HourlyWeather> _next(Forecast f, int hours) => f.hourly.take(hours);

double _maxOf(Iterable<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

double _avgOf(Iterable<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

LifeIndex _laundry(Forecast f) {
  final window = _next(f, 6).toList();
  final rainChance = _maxOf(window.map((h) => h.precipitationProbability));
  final humidity = _avgOf(window.map((h) => h.humidity));
  final temperature = _avgOf(window.map((h) => h.temperature));
  final wind = _avgOf(window.map((h) => h.windSpeed));
  const activity = LifeActivity.laundry;
  if (rainChance >= 50) {
    return const LifeIndex(
      activity,
      IndexRating.poor,
      IndexReason.rainExpected,
    );
  }
  if (humidity >= 85) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.tooHumid);
  }
  if (temperature < 3) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.tooCold);
  }
  if (rainChance >= 30 || humidity >= 70 || (temperature < 10 && wind < 10)) {
    return LifeIndex(
      activity,
      IndexRating.fair,
      rainChance >= 30 ? IndexReason.rainExpected : IndexReason.tooHumid,
    );
  }
  return const LifeIndex(activity, IndexRating.good, IndexReason.goodDrying);
}

LifeIndex _carWash(Forecast f) {
  final rainChance = _maxOf(
    _next(f, 48).map((h) => h.precipitationProbability),
  );
  const activity = LifeActivity.carWash;
  if ((f.air?.pm10 ?? 0) >= 150 || (f.air?.dust ?? 0) >= 100) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.dusty);
  }
  if (f.current.temperature < 0) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.freezing);
  }
  if (rainChance >= 40) {
    return const LifeIndex(
      activity,
      IndexRating.poor,
      IndexReason.rainExpected,
    );
  }
  if (rainChance >= 20) {
    return const LifeIndex(
      activity,
      IndexRating.fair,
      IndexReason.rainExpected,
    );
  }
  return const LifeIndex(activity, IndexRating.good, IndexReason.dryDaysAhead);
}

LifeIndex _exercise(
  Forecast f,
  LifeActivity activity, {
  required double windyAt,
  required double gustyAt,
}) {
  final window = _next(f, 3).toList();
  final feels = f.current.apparentTemperature;
  final aqi = f.air?.usAqi ?? 0;
  final gust = _maxOf(window.map((h) => h.windGusts));
  final wind = _avgOf(window.map((h) => h.windSpeed));
  final wet = window.any((h) => h.condition.isWet || h.condition.isSnowy);
  if (window.any((h) => h.condition.isStormy)) {
    return LifeIndex(activity, IndexRating.poor, IndexReason.stormy);
  }
  if (feels >= 33) {
    return LifeIndex(activity, IndexRating.poor, IndexReason.tooHot);
  }
  if (feels <= -10) {
    return LifeIndex(activity, IndexRating.poor, IndexReason.tooCold);
  }
  if (aqi >= 150) {
    return LifeIndex(activity, IndexRating.poor, IndexReason.badAir);
  }
  if (gust >= gustyAt) {
    return LifeIndex(activity, IndexRating.poor, IndexReason.windy);
  }
  if (feels >= 27) {
    return LifeIndex(activity, IndexRating.fair, IndexReason.tooHot);
  }
  if (feels <= 0) {
    return LifeIndex(activity, IndexRating.fair, IndexReason.tooCold);
  }
  if (aqi >= 100) {
    return LifeIndex(activity, IndexRating.fair, IndexReason.badAir);
  }
  if (wind >= windyAt) {
    return LifeIndex(activity, IndexRating.fair, IndexReason.windy);
  }
  if (wet) return LifeIndex(activity, IndexRating.fair, IndexReason.wet);
  return LifeIndex(activity, IndexRating.good, IndexReason.pleasant);
}

LifeIndex _walking(Forecast f) {
  final window = _next(f, 4).toList();
  final feels = f.current.apparentTemperature;
  final aqi = f.air?.usAqi ?? 0;
  final rainChance = _maxOf(window.map((h) => h.precipitationProbability));
  const activity = LifeActivity.walking;
  if (window.any((h) => h.condition.isStormy)) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.stormy);
  }
  if (rainChance >= 60) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.wet);
  }
  if (aqi >= 150) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.badAir);
  }
  if (feels >= 35) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.tooHot);
  }
  if (feels <= -5) {
    return const LifeIndex(activity, IndexRating.poor, IndexReason.tooCold);
  }
  final comfortable = feels >= 14 && feels <= 28;
  if (comfortable && rainChance < 30 && aqi < 100) {
    return const LifeIndex(activity, IndexRating.good, IndexReason.pleasant);
  }
  return LifeIndex(
    activity,
    IndexRating.fair,
    feels > 28
        ? IndexReason.tooHot
        : feels < 14
        ? IndexReason.tooCold
        : rainChance >= 30
        ? IndexReason.wet
        : IndexReason.badAir,
  );
}

/// Cloud cover over tonight's dark hours (21:00–02:00).
LifeIndex _stargazing(Forecast f) {
  final night = f.hourly
      .where((h) => h.time.hour >= 21 || h.time.hour <= 2)
      .take(6)
      .map((h) => h.cloudCover);
  final cover = _avgOf(night);
  const activity = LifeActivity.stargazing;
  if (cover < 20) {
    return const LifeIndex(activity, IndexRating.good, IndexReason.clearSky);
  }
  if (cover < 50) {
    return const LifeIndex(activity, IndexRating.fair, IndexReason.someClouds);
  }
  return const LifeIndex(activity, IndexRating.poor, IndexReason.cloudy);
}
