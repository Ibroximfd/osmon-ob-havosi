import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/domain/weather_condition.dart';
import 'route_models.dart';

const double _minSpacingKm = 30;
const double _maxSpacingKm = 80;
const int _targetCheckpoints = 8;

/// Points along [path] spaced evenly by road distance, origin and
/// destination included, each with its distance from the start.
List<({GeoPoint point, double distanceKm})> sampleCheckpoints(RoutePath path) {
  final points = path.points;
  if (points.length < 2) {
    return <({GeoPoint point, double distanceKm})>[
      for (final p in points) (point: p, distanceKm: 0),
    ];
  }
  final segments = <double>[
    for (var i = 1; i < points.length; i++)
      points[i - 1].distanceKmTo(points[i]),
  ];
  final geometric = segments.fold<double>(0, (a, b) => a + b);
  // Scale geometry to the reported road distance so ETAs line up.
  final scale = geometric == 0 ? 1.0 : path.distanceKm / geometric;
  final spacing = (path.distanceKm / _targetCheckpoints).clamp(
    _minSpacingKm,
    _maxSpacingKm,
  );

  final samples = <({GeoPoint point, double distanceKm})>[
    (point: points.first, distanceKm: 0),
  ];
  var travelled = 0.0;
  var nextMark = spacing;
  for (var i = 0; i < segments.length; i++) {
    final length = segments[i] * scale;
    while (travelled + length >= nextMark &&
        nextMark < path.distanceKm - spacing / 2) {
      final fraction = length == 0 ? 0.0 : (nextMark - travelled) / length;
      samples.add((
        point: points[i].lerp(points[i + 1], fraction),
        distanceKm: nextMark,
      ));
      nextMark += spacing;
    }
    travelled += length;
  }
  samples.add((point: points.last, distanceKm: path.distanceKm));
  return samples;
}

/// Fog below 1 km visibility and gusts from 60 km/h are the thresholds
/// road services use for driver warnings.
Set<RouteHazard> hazardsOf(PointHour hour) {
  final c = hour.condition;
  final freezing =
      c == WeatherCondition.freezingRain ||
      c == WeatherCondition.freezingDrizzle;
  final lowVisibility = hour.visibility > 0 && hour.visibility < 1000;
  return <RouteHazard>{
    if (c.isStormy) RouteHazard.storm,
    if (freezing || (hour.temperature <= 0 && (c.isWet || c.isSnowy)))
      RouteHazard.ice,
    if (c.isSnowy || hour.snowfall > 0) RouteHazard.snow,
    if (lowVisibility || c == WeatherCondition.fog) RouteHazard.fog,
    if (c == WeatherCondition.heavyRain || c == WeatherCondition.rainShowers)
      RouteHazard.heavyRain,
    if (hour.windGusts >= 60) RouteHazard.strongWind,
  };
}

/// Builds the plan for one departure (origin local time).
RoutePlan buildPlan({
  required Place from,
  required Place to,
  required RoutePath path,
  required DateTime departure,
  required int originOffsetSeconds,
  required List<({GeoPoint point, double distanceKm})> samples,
  required List<PointForecast> forecasts,
}) {
  List<RouteCheckpoint> checkpointsFor(DateTime start) => <RouteCheckpoint>[
    for (var i = 0; i < samples.length; i++)
      _checkpoint(
        sample: samples[i],
        forecast: i < forecasts.length ? forecasts[i] : null,
        departure: start,
        path: path,
        originOffsetSeconds: originOffsetSeconds,
      ),
  ];

  int hazardCount(List<RouteCheckpoint> list) =>
      list.fold(0, (sum, c) => sum + c.hazards.length);

  final checkpoints = checkpointsFor(departure);
  Duration? better;
  final baseline = hazardCount(checkpoints);
  if (baseline > 0) {
    for (final hours in <int>[1, 2, 3]) {
      final delay = Duration(hours: hours);
      if (hazardCount(checkpointsFor(departure.add(delay))) == 0) {
        better = delay;
        break;
      }
    }
  }
  return RoutePlan(
    from: from,
    to: to,
    path: path,
    departure: departure,
    checkpoints: checkpoints,
    betterDelay: better,
  );
}

RouteCheckpoint _checkpoint({
  required ({GeoPoint point, double distanceKm}) sample,
  required PointForecast? forecast,
  required DateTime departure,
  required RoutePath path,
  required int originOffsetSeconds,
}) {
  final fraction = path.distanceKm == 0
      ? 0.0
      : sample.distanceKm / path.distanceKm;
  final travel = Duration(
    seconds: (path.duration.inSeconds * fraction).round(),
  );
  final etaOrigin = departure.add(travel);
  final localOffset = forecast?.utcOffsetSeconds ?? originOffsetSeconds;
  final eta = etaOrigin.add(
    Duration(seconds: localOffset - originOffsetSeconds),
  );
  final hour = forecast == null ? null : _hourAt(forecast.hours, eta);
  return RouteCheckpoint(
    point: sample.point,
    distanceKm: sample.distanceKm,
    eta: eta,
    weather: hour,
    hazards: hour == null ? const <RouteHazard>{} : hazardsOf(hour),
  );
}

PointHour? _hourAt(List<PointHour> hours, DateTime time) {
  PointHour? best;
  for (final hour in hours) {
    if (hour.time.isAfter(time)) break;
    best = hour;
  }
  return best ?? (hours.isEmpty ? null : hours.first);
}
