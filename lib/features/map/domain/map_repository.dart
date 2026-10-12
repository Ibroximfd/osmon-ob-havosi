import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import 'weather_grid.dart';

abstract interface class MapRepository {
  /// Current OpenFreeMap vector tile URL template (`…/{z}/{x}/{y}.pbf`).
  /// Resolved from TileJSON, cached for offline starts.
  Future<Either<DataFailure, String>> resolveTileTemplate();

  /// One multi-location forecast request covering a grid over [bounds] and
  /// the [named] places inside it. Adds US AQI when [withAirQuality].
  Future<Either<DataFailure, WeatherGrid>> loadGrid(
    GeoBounds bounds, {
    required List<Place> named,
    required bool withAirQuality,
  });
}
