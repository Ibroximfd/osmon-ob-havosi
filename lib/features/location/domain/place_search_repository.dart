import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';

abstract interface class PlaceSearchRepository {
  /// `GET geocoding-api.open-meteo.com/v1/search?name=…` — cities worldwide,
  /// named in [languageCode] where GeoNames has a translation.
  Future<Either<DataFailure, List<Place>>> search(
    String query, {
    required String languageCode,
  });
}
