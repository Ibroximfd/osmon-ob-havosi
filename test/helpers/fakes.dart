import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/error/data_failure.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/ai/domain/ai_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/ai/domain/chat_turn.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/location/domain/location_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/location/domain/place_search_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/app_settings.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/notification_permissions.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/settings_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/weather_repository.dart';

final class FakeWeatherRepository implements WeatherRepository {
  FakeWeatherRepository({required this.result, this.cached});

  Either<DataFailure, Forecast> result;
  Forecast? cached;
  final List<Place> requested = <Place>[];

  @override
  Future<Either<DataFailure, Forecast>> loadForecast(Place place) async {
    requested.add(place);
    return result;
  }

  @override
  Future<Forecast?> readCachedForecast(Place place) async => cached;

  @override
  Future<Either<DataFailure, PastDay>> loadSameDayLastYear(
    Place place,
    DateTime today,
  ) async => const Left<DataFailure, PastDay>(OfflineFailure());
}

final class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({
    this.selected,
    this.locateResult = const Left<DataFailure, Place>(PermissionFailure()),
    this.region,
    this.access = LocationAccess.granted,
  });

  Place? selected;
  Either<DataFailure, Place> locateResult;
  String? region;
  LocationAccess access;
  final StreamController<Place> _changes = StreamController<Place>.broadcast();

  @override
  Place? get selectedPlace => selected;

  @override
  Stream<Place> watchSelectedPlace() => _changes.stream;

  @override
  Future<void> selectPlace(Place place) async {
    selected = place;
    _changes.add(place);
  }

  @override
  Future<Either<DataFailure, Place>> locateDevice({
    required String languageCode,
    bool prompt = true,
  }) async => locateResult;

  @override
  Future<LocationAccess> checkAccess() async => access;

  @override
  String? deviceRegionCode() => region;

  @override
  Future<void> openLocationSettings({required bool servicesDisabled}) async {}
}

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([
    this._current = const AppSettings(languageCode: 'uz'),
  ]);

  AppSettings _current;
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast();

  @override
  AppSettings get current => _current;

  @override
  Stream<AppSettings> watch() => _changes.stream;

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
    _changes.add(settings);
  }
}

final class FakePermissions implements NotificationPermissions {
  const FakePermissions({required this.granted});

  final bool granted;

  @override
  Future<bool> request() async => granted;

  @override
  Future<bool> isGranted() async => granted;

  @override
  Future<void> openSettings() async {}
}

final class FakeAiRepository implements AiRepository {
  const FakeAiRepository();

  @override
  bool get isConfigured => false;

  @override
  Future<Either<DataFailure, String>> writeDayStory(
    Forecast forecast, {
    required String languageCode,
  }) async => const Left<DataFailure, String>(UnconfiguredFailure());

  @override
  Future<Either<DataFailure, String>> reply(
    List<ChatTurn> conversation, {
    required String languageCode,
    Forecast? forecast,
  }) async => const Left<DataFailure, String>(UnconfiguredFailure());

  @override
  Future<Either<DataFailure, String>> describePhoto(
    Uint8List bytes, {
    required String mimeType,
    required String languageCode,
  }) async => const Left<DataFailure, String>(UnconfiguredFailure());

  @override
  Future<Either<DataFailure, Uint8List>> restylePhoto(
    Uint8List bytes, {
    required String mimeType,
    required String instruction,
  }) async => const Left<DataFailure, Uint8List>(UnconfiguredFailure());
}

final class FakePlaceSearch implements PlaceSearchRepository {
  FakePlaceSearch(this.results);

  final Map<String, List<Place>> results;

  @override
  Future<Either<DataFailure, List<Place>>> search(
    String query, {
    required String languageCode,
  }) async =>
      Right<DataFailure, List<Place>>(results[query] ?? const <Place>[]);
}
