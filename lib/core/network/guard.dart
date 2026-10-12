import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../error/data_failure.dart';

/// The one place transport exceptions become [DataFailure]s. Repositories
/// wrap each call in it so nothing above the data layer sees Dio.
Future<Either<DataFailure, T>> guard<T>(Future<T> Function() call) async {
  try {
    return Right<DataFailure, T>(await call());
  } on DioException catch (error) {
    return Left<DataFailure, T>(mapDioException(error));
  } on FormatException catch (error) {
    // A payload we cannot read is a server contract break, not a user issue.
    return Left<DataFailure, T>(ServerFailure('malformed payload: $error'));
  }
}

DataFailure mapDioException(DioException error) => switch (error.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.connectionError => const OfflineFailure(),
  DioExceptionType.badResponse => switch (error.response?.statusCode) {
    404 => const NotFoundFailure(),
    429 => const QuotaFailure(),
    final code => ServerFailure('HTTP $code'),
  },
  DioExceptionType.cancel ||
  DioExceptionType.badCertificate ||
  DioExceptionType.unknown => ServerFailure(error.message ?? 'unknown'),
};
