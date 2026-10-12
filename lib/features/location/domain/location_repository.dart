import 'package:dartz/dartz.dart';

import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';

/// What the app may do with the device position right now.
enum LocationAccess {
  granted,

  /// Not granted yet; the system dialog can still ask.
  denied,

  /// Refused for good: only the app's system settings can grant it.
  deniedForever,

  /// Location is switched off for the whole device.
  servicesOff,
}

/// The place the app currently shows, and the device's own position.
abstract interface class LocationRepository {
  Place? get selectedPlace;

  /// Emits whenever another part of the app selects a place.
  Stream<Place> watchSelectedPlace();

  Future<void> selectPlace(Place place);

  /// Resolves the GPS position into a named place. Fails with
  /// [PermissionFailure] when refused and [ServiceDisabledFailure] when
  /// location is switched off; never prompts if [prompt] is false.
  Future<Either<DataFailure, Place>> locateDevice({
    required String languageCode,
    bool prompt = true,
  });

  /// Current access to the device position, without prompting.
  Future<LocationAccess> checkAccess();

  /// ISO country code of the device's region setting (`UZ`), if any.
  String? deviceRegionCode();

  Future<void> openLocationSettings({required bool servicesDisabled});
}
