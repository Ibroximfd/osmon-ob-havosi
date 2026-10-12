// Test-only support for the store renderer: seeding state through emit is
// exactly what these Blocs exist for, so the visible-for-testing rule is
// relaxed in this file.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dartz/dartz.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/geo_point.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/error/data_failure.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/domain/alerts_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/domain/weather_alert.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/presentation/bloc/alerts_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/domain/field_conditions.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/domain/field_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/presentation/bloc/field_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/domain/air_quality.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/domain/air_quality_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/presentation/bloc/health_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/domain/route_models.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/domain/route_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/presentation/bloc/route_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/bloc/weather_bloc.dart';

import '../../test/helpers/fakes.dart';

/// Blocs whose state is set directly, so each store frame shows a chosen,
/// realistic moment instead of whatever the network returns today.
final class SeededWeatherBloc extends WeatherBloc {
  SeededWeatherBloc(WeatherState state)
    : super(
        weather: FakeWeatherRepository(
          result: const Left<DataFailure, Forecast>(OfflineFailure()),
        ),
        location: FakeLocationRepository(selected: UzbekCities.tashkent),
        settings: FakeSettingsRepository(),
        ai: const FakeAiRepository(),
      ) {
    emit(state);
  }

  @override
  void add(WeatherEvent event) {}
}

final class _NoAir implements AirQualityRepository {
  @override
  Future<Either<DataFailure, AirQualityReport>> loadReport(Place place) async =>
      const Left<DataFailure, AirQualityReport>(OfflineFailure());
}

final class SeededHealthBloc extends HealthBloc {
  SeededHealthBloc(HealthState state)
    : super(_NoAir(), FakeLocationRepository(selected: state.place)) {
    emit(state);
  }

  @override
  void add(HealthEvent event) {}
}

final class _FieldStub implements FieldRepository {
  @override
  Future<Either<DataFailure, FieldConditions>> loadConditions(
    Place place,
  ) async => const Left<DataFailure, FieldConditions>(OfflineFailure());

  @override
  Crop get savedCrop => Crop.wheat;

  @override
  Future<void> saveCrop(Crop crop) async {}
}

final class SeededFieldBloc extends FieldBloc {
  SeededFieldBloc(FieldState state)
    : super(_FieldStub(), FakeLocationRepository(selected: state.place)) {
    emit(state);
  }

  @override
  void add(FieldEvent event) {}
}

final class _RouteStub implements RouteRepository {
  @override
  Future<Either<DataFailure, RoutePath>> findPath(Place from, Place to) async =>
      const Left<DataFailure, RoutePath>(OfflineFailure());

  @override
  Future<Either<DataFailure, List<PointForecast>>> loadPointForecasts(
    List<GeoPoint> points,
  ) async => const Left<DataFailure, List<PointForecast>>(OfflineFailure());

  @override
  Future<String?> nameOf(
    GeoPoint point, {
    required String languageCode,
  }) async => null;

  @override
  List<SavedRoute> get savedRoutes => const <SavedRoute>[];

  @override
  Future<void> toggleSaved(SavedRoute route) async {}
}

final class SeededRouteBloc extends RouteBloc {
  SeededRouteBloc(RouteState state)
    : super(
        routes: _RouteStub(),
        location: FakeLocationRepository(selected: state.from),
        settings: FakeSettingsRepository(),
      ) {
    emit(state);
  }

  @override
  void add(RouteEvent event) {}
}

final class _AlertsStub implements AlertsRepository {
  @override
  Future<Either<DataFailure, Map<Place, List<RegionDay>>>> loadRegionDays(
    List<Place> places,
  ) async =>
      const Left<DataFailure, Map<Place, List<RegionDay>>>(OfflineFailure());
}

final class SeededAlertsBloc extends AlertsBloc {
  SeededAlertsBloc(AlertsState state)
    : super(_AlertsStub(), FakeLocationRepository(selected: state.ownPlace)) {
    emit(state);
  }

  @override
  void add(AlertsEvent event) {}
}
