import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import 'air_quality.dart';

abstract interface class AirQualityRepository {
  /// `GET air-quality-api.open-meteo.com/v1/air-quality` — current values
  /// and a three-day hourly outlook.
  Future<Either<DataFailure, AirQualityReport>> loadReport(Place place);
}
