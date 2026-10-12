import 'package:equatable/equatable.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/domain/weather_condition.dart';

final class RoutePath extends Equatable {
  const RoutePath({
    required this.points,
    required this.distanceKm,
    required this.duration,
    required this.isEstimated,
  });

  /// Road geometry, origin first.
  final List<GeoPoint> points;
  final double distanceKm;
  final Duration duration;

  /// True when the road service was unavailable and the path is a straight
  /// line with an average-speed estimate.
  final bool isEstimated;

  @override
  List<Object?> get props => <Object?>[
    points,
    distanceKm,
    duration,
    isEstimated,
  ];
}

/// Hourly weather at one point along the road, in that point's local time.
final class PointHour extends Equatable {
  const PointHour({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.precipitationProbability,
    required this.visibility,
    required this.windGusts,
    required this.snowfall,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final WeatherCondition condition;
  final double precipitationProbability;

  /// Metres.
  final double visibility;
  final double windGusts;

  /// cm in the hour.
  final double snowfall;
  final bool isDay;

  @override
  List<Object?> get props => <Object?>[
    time,
    temperature,
    condition,
    precipitationProbability,
    visibility,
    windGusts,
    snowfall,
    isDay,
  ];
}

final class PointForecast extends Equatable {
  const PointForecast({required this.utcOffsetSeconds, required this.hours});

  final int utcOffsetSeconds;
  final List<PointHour> hours;

  @override
  List<Object?> get props => <Object?>[utcOffsetSeconds, hours];
}

enum RouteHazard { storm, ice, snow, fog, heavyRain, strongWind }

final class RouteCheckpoint extends Equatable {
  const RouteCheckpoint({
    required this.point,
    required this.distanceKm,
    required this.eta,
    required this.weather,
    required this.hazards,
    this.name,
  });

  final GeoPoint point;
  final double distanceKm;

  /// Arrival in the checkpoint's local time.
  final DateTime eta;
  final PointHour? weather;
  final Set<RouteHazard> hazards;

  /// Settlement name when the geocoder knows one.
  final String? name;

  RouteCheckpoint withName(String? value) => RouteCheckpoint(
    point: point,
    distanceKm: distanceKm,
    eta: eta,
    weather: weather,
    hazards: hazards,
    name: value,
  );

  @override
  List<Object?> get props => <Object?>[
    point,
    distanceKm,
    eta,
    weather,
    hazards,
    name,
  ];
}

final class RoutePlan extends Equatable {
  const RoutePlan({
    required this.from,
    required this.to,
    required this.path,
    required this.departure,
    required this.checkpoints,
    this.betterDelay,
  });

  final Place from;
  final Place to;
  final RoutePath path;

  /// Origin local time.
  final DateTime departure;
  final List<RouteCheckpoint> checkpoints;

  /// A later departure that avoids the hazards, if one exists within three
  /// hours.
  final Duration? betterDelay;

  bool get hasHazards => checkpoints.any((c) => c.hazards.isNotEmpty);

  @override
  List<Object?> get props => <Object?>[
    from,
    to,
    path,
    departure,
    checkpoints,
    betterDelay,
  ];
}

final class SavedRoute extends Equatable {
  const SavedRoute(this.from, this.to);

  final Place from;
  final Place to;

  String get key => '${from.key}>${to.key}';

  @override
  List<Object?> get props => <Object?>[from, to];
}
