import 'package:equatable/equatable.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';

enum MapLayer { temperature, precipitation, wind, clouds, airQuality }

final class GeoBounds extends Equatable {
  const GeoBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;

  bool contains(GeoPoint point) =>
      point.latitude >= south &&
      point.latitude <= north &&
      point.longitude >= west &&
      point.longitude <= east;

  /// Evenly spaced sample points, inset half a cell from the edges.
  List<GeoPoint> grid({required int columns, required int rows}) {
    final latStep = (north - south) / rows;
    final lonStep = (east - west) / columns;
    return <GeoPoint>[
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < columns; c++)
          GeoPoint(south + latStep * (r + 0.5), west + lonStep * (c + 0.5)),
    ];
  }

  /// True when [other] is close enough that refetching adds nothing.
  bool roughlyEquals(GeoBounds other) {
    final tolerance = (north - south) * 0.15;
    return (south - other.south).abs() < tolerance &&
        (north - other.north).abs() < tolerance &&
        (west - other.west).abs() < tolerance &&
        (east - other.east).abs() < tolerance;
  }

  @override
  List<Object?> get props => <Object?>[south, west, north, east];
}

final class GridCell extends Equatable {
  const GridCell({
    required this.point,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudCover,
    required this.precipitationSteps,
    this.usAqi,
    this.place,
  });

  final GeoPoint point;
  final double temperature;
  final double windSpeed;
  final double windDirection;
  final double cloudCover;

  /// mm per 15 minutes for each timeline step (now … +2 h).
  final List<double> precipitationSteps;
  final double? usAqi;

  /// Set for named markers (regional centres); null for plain grid cells.
  final Place? place;

  @override
  List<Object?> get props => <Object?>[
    point,
    temperature,
    windSpeed,
    windDirection,
    cloudCover,
    precipitationSteps,
    usAqi,
    place,
  ];
}

final class WeatherGrid extends Equatable {
  const WeatherGrid({
    required this.bounds,
    required this.cells,
    required this.stepTimes,
  });

  final GeoBounds bounds;
  final List<GridCell> cells;

  /// Place-time label for each precipitation step.
  final List<DateTime> stepTimes;

  Iterable<GridCell> get namedCells => cells.where((c) => c.place != null);

  Iterable<GridCell> get fieldCells => cells.where((c) => c.place == null);

  @override
  List<Object?> get props => <Object?>[bounds, cells, stepTimes];
}
