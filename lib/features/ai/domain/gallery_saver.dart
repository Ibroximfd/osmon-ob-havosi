import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../core/error/data_failure.dart';

abstract interface class GallerySaver {
  /// Saves image bytes to the device gallery; [PermissionFailure] when the
  /// user refuses photo access.
  Future<Either<DataFailure, Unit>> save(Uint8List bytes);
}
