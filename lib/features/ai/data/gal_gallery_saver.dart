import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:gal/gal.dart';

import '../../../core/error/data_failure.dart';
import '../domain/gallery_saver.dart';

final class GalGallerySaver implements GallerySaver {
  const GalGallerySaver();

  @override
  Future<Either<DataFailure, Unit>> save(Uint8List bytes) async {
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
      return const Left<DataFailure, Unit>(PermissionFailure());
    }
    try {
      await Gal.putImageBytes(
        bytes,
        name: 'osmon_${DateTime.now().millisecondsSinceEpoch}',
      );
      return const Right<DataFailure, Unit>(unit);
    } on GalException catch (error) {
      return Left<DataFailure, Unit>(ServerFailure(error.type.message));
    }
  }
}
