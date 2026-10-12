import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import 'weather_alert.dart';

abstract interface class AlertsRepository {
  /// Three days of daily forecasts for every place in one multi-location
  /// request, plus dust maxima from the air-quality API.
  Future<Either<DataFailure, Map<Place, List<RegionDay>>>> loadRegionDays(
    List<Place> places,
  );
}
