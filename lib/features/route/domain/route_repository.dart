import 'package:dartz/dartz.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import 'route_models.dart';

abstract interface class RouteRepository {
  /// `GET router.project-osrm.org/route/v1/driving/…`; falls back to a
  /// straight-line estimate when the road service is unavailable.
  Future<Either<DataFailure, RoutePath>> findPath(Place from, Place to);

  /// One multi-location Open-Meteo request for all checkpoints.
  Future<Either<DataFailure, List<PointForecast>>> loadPointForecasts(
    List<GeoPoint> points,
  );

  /// Best-effort settlement name for a point (platform geocoder).
  Future<String?> nameOf(GeoPoint point, {required String languageCode});

  List<SavedRoute> get savedRoutes;

  Future<void> toggleSaved(SavedRoute route);
}
