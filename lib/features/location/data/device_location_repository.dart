import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/platform/external_flow.dart';
import '../domain/location_repository.dart';

/// GPS through geolocator, names through the platform geocoder (free, on
/// device), the selection in SharedPreferences.
final class DeviceLocationRepository implements LocationRepository {
  DeviceLocationRepository(this._prefs)
    : _selected = _readSelected(_prefs) ?? _readLegacy(_prefs);

  final SharedPreferences _prefs;
  final StreamController<Place> _changes = StreamController<Place>.broadcast();
  Place? _selected;

  static const String _selectedKey = 'v2.selected_place';
  static const String _legacyLat = 'last_known_lat';
  static const String _legacyLon = 'last_known_lon';
  static const String _legacyName = 'last_known_city_name';

  static const Duration _positionTimeout = Duration(seconds: 8);
  static const Duration _geocodeTimeout = Duration(seconds: 5);

  @override
  Place? get selectedPlace => _selected;

  @override
  Stream<Place> watchSelectedPlace() => _changes.stream;

  @override
  Future<void> selectPlace(Place place) async {
    _selected = place;
    _changes.add(place);
    await _prefs.setString(_selectedKey, jsonEncode(place.toJson()));
  }

  @override
  Future<Either<DataFailure, Place>> locateDevice({
    required String languageCode,
    bool prompt = true,
  }) async {
    // Permission first: the dialog works with location switched off, so a
    // user who allows it now only has to flip the switch later.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && prompt) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return const Left<DataFailure, Place>(PermissionFailure());
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const Left<DataFailure, Place>(ServiceDisabledFailure());
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _positionTimeout,
        ),
      );
      final point = GeoPoint(position.latitude, position.longitude);
      return Right<DataFailure, Place>(await _name(point, languageCode));
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) return const Left<DataFailure, Place>(OfflineFailure());
      final point = GeoPoint(last.latitude, last.longitude);
      return Right<DataFailure, Place>(await _name(point, languageCode));
    } on LocationServiceDisabledException {
      return const Left<DataFailure, Place>(ServiceDisabledFailure());
    } on PermissionDeniedException {
      return const Left<DataFailure, Place>(PermissionFailure());
    }
  }

  /// Best effort: the geocoder can be slow or offline, and coordinates are
  /// still a usable place without a name.
  Future<Place> _name(GeoPoint point, String languageCode) async {
    try {
      await setLocaleIdentifier(languageCode);
      final marks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      ).timeout(_geocodeTimeout);
      final mark = marks.isEmpty ? null : marks.first;
      final name = _firstNonEmpty(<String?>[
        mark?.locality,
        mark?.subAdministrativeArea,
        mark?.administrativeArea,
      ]);
      return Place(
        name: name ?? _coordinatesLabel(point),
        point: point,
        region: _nonEmpty(mark?.administrativeArea),
        countryCode: _nonEmpty(mark?.isoCountryCode)?.toUpperCase(),
        isCurrentLocation: true,
      );
    } on TimeoutException {
      return Place(
        name: _coordinatesLabel(point),
        point: point,
        isCurrentLocation: true,
      );
    } on NoResultFoundException {
      return Place(
        name: _coordinatesLabel(point),
        point: point,
        isCurrentLocation: true,
      );
    }
  }

  @override
  Future<LocationAccess> checkAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.servicesOff;
    }
    return switch (await Geolocator.checkPermission()) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      LocationPermission.denied ||
      LocationPermission.unableToDetermine => LocationAccess.denied,
    };
  }

  @override
  String? deviceRegionCode() =>
      PlatformDispatcher.instance.locale.countryCode?.toUpperCase();

  @override
  Future<void> openLocationSettings({required bool servicesDisabled}) async {
    // The user comes back whenever they like; keep the app-open ad away.
    ExternalFlow.markLeaving();
    await (servicesDisabled
        ? Geolocator.openLocationSettings()
        : Geolocator.openAppSettings());
  }

  static String _coordinatesLabel(GeoPoint point) =>
      '${point.latitude.toStringAsFixed(2)}°, ${point.longitude.toStringAsFixed(2)}°';

  static String? _nonEmpty(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = _nonEmpty(value);
      if (trimmed != null) return trimmed;
    }
    return null;
  }

  static Place? _readSelected(SharedPreferences prefs) {
    final raw = prefs.getString(_selectedKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? Place.fromJson(decoded) : null;
  }

  /// 1.x stored the last GPS city as three loose keys.
  static Place? _readLegacy(SharedPreferences prefs) {
    final lat = prefs.getDouble(_legacyLat);
    final lon = prefs.getDouble(_legacyLon);
    final name = prefs.getString(_legacyName);
    if (lat == null || lon == null || name == null) return null;
    return Place(
      name: name,
      point: GeoPoint(lat, lon),
      isCurrentLocation: true,
    );
  }
}
