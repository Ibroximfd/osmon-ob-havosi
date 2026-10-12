import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import 'field_conditions.dart';

abstract interface class FieldRepository {
  /// Soil and agro variables from `api.open-meteo.com/v1/forecast`, plus the
  /// season's daily temperatures from the archive API.
  Future<Either<DataFailure, FieldConditions>> loadConditions(Place place);

  Crop get savedCrop;

  Future<void> saveCrop(Crop crop);
}
