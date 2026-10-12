import 'dart:math' as math;

import 'package:equatable/equatable.dart';

final class GeoPoint extends Equatable {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  static const double _earthRadiusKm = 6371;

  /// Great-circle distance (haversine), in kilometres.
  double distanceKmTo(GeoPoint other) {
    final dLat = _rad(other.latitude - latitude);
    final dLon = _rad(other.longitude - longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(latitude)) *
            math.cos(_rad(other.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * _earthRadiusKm * math.asin(math.sqrt(a));
  }

  /// The point a [fraction] of the way to [other] along a straight segment.
  /// Good enough for the short spans between road vertices.
  GeoPoint lerp(GeoPoint other, double fraction) => GeoPoint(
    latitude + (other.latitude - latitude) * fraction,
    longitude + (other.longitude - longitude) * fraction,
  );

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  List<Object?> get props => <Object?>[latitude, longitude];
}
