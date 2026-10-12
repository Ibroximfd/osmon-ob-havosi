import 'package:equatable/equatable.dart';

/// Every expected failure the data layer can report. Screens map these onto
/// the states gallery, so add a variant only when a screen must react
/// differently.
sealed class DataFailure extends Equatable {
  const DataFailure();

  @override
  List<Object?> get props => const <Object?>[];
}

/// No connection or the request timed out — a neutral, retryable state.
final class OfflineFailure extends DataFailure {
  const OfflineFailure();
}

/// The server answered with an error or a payload we could not read.
final class ServerFailure extends DataFailure {
  const ServerFailure([this.detail = '']);

  final String detail;

  @override
  List<Object?> get props => <Object?>[detail];
}

final class NotFoundFailure extends DataFailure {
  const NotFoundFailure();
}

/// The user declined a platform permission (location, notifications).
final class PermissionFailure extends DataFailure {
  const PermissionFailure();
}

/// Location services are switched off on the device — distinct from a
/// denied permission because the fix is a different settings screen.
final class ServiceDisabledFailure extends DataFailure {
  const ServiceDisabledFailure();
}

/// A rate-limited upstream (HTTP 429) — retry later, not now.
final class QuotaFailure extends DataFailure {
  const QuotaFailure();
}

/// A feature whose credentials are not configured in this build (AI key).
final class UnconfiguredFailure extends DataFailure {
  const UnconfiguredFailure();
}
