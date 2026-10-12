import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import 'entities/forecast.dart';

abstract interface class WeatherRepository {
  /// `GET api.open-meteo.com/v1/forecast` plus the air-quality current
  /// values, network-first. A successful load is cached for offline use.
  Future<Either<DataFailure, Forecast>> loadForecast(Place place);

  /// The last forecast saved for [place], re-anchored to "now", or null.
  Future<Forecast?> readCachedForecast(Place place);

  /// `GET archive-api.open-meteo.com/v1/archive` for one day a year ago.
  Future<Either<DataFailure, PastDay>> loadSameDayLastYear(
    Place place,
    DateTime today,
  );
}
