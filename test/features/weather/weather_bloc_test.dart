import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/bloc/load_status.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/error/data_failure.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/location/domain/location_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/bloc/weather_bloc.dart';

import '../../helpers/fakes.dart';
import '../../helpers/forecast_fixture.dart';

void main() {
  final forecast = buildForecast();

  WeatherBloc build({
    required FakeWeatherRepository weather,
    required FakeLocationRepository location,
  }) => WeatherBloc(
    weather: weather,
    location: location,
    settings: FakeSettingsRepository(),
    ai: const FakeAiRepository(),
  );

  group('WeatherBloc', () {
    blocTest<WeatherBloc, WeatherState>(
      'a saved place loads straight to ready',
      build: () => build(
        weather: FakeWeatherRepository(
          result: Right<DataFailure, Forecast>(forecast),
        ),
        location: FakeLocationRepository(selected: UzbekCities.tashkent),
      ),
      act: (bloc) => bloc.add(const WeatherStarted()),
      expect: () => <Matcher>[
        isA<WeatherState>().having(
          (s) => s.locationAccess,
          'locationAccess',
          LocationAccess.granted,
        ),
        isA<WeatherState>().having(
          (s) => s.status,
          'status',
          LoadStatus.loading,
        ),
        isA<WeatherState>()
            .having((s) => s.status, 'status', LoadStatus.ready)
            .having((s) => s.forecast, 'forecast', forecast),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'offline falls back to the cached forecast with the offline status',
      build: () => build(
        weather: FakeWeatherRepository(
          result: const Left<DataFailure, Forecast>(OfflineFailure()),
          cached: forecast,
        ),
        location: FakeLocationRepository(selected: UzbekCities.tashkent),
      ),
      act: (bloc) => bloc.add(const WeatherStarted()),
      skip: 2,
      expect: () => <Matcher>[
        isA<WeatherState>()
            .having((s) => s.status, 'status', LoadStatus.offline)
            .having((s) => s.forecast, 'forecast', forecast),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'a server error without cache is a failure',
      build: () => build(
        weather: FakeWeatherRepository(
          result: const Left<DataFailure, Forecast>(ServerFailure('HTTP 500')),
        ),
        location: FakeLocationRepository(selected: UzbekCities.tashkent),
      ),
      act: (bloc) => bloc.add(const WeatherStarted()),
      skip: 2,
      expect: () => <Matcher>[
        isA<WeatherState>()
            .having((s) => s.status, 'status', LoadStatus.failure)
            .having((s) => s.forecast, 'forecast', isNull),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'refused location in Uzbekistan falls back to Tashkent and keeps the hint',
      build: () => build(
        weather: FakeWeatherRepository(
          result: Right<DataFailure, Forecast>(forecast),
        ),
        location: FakeLocationRepository(
          region: 'UZ',
          access: LocationAccess.denied,
        ),
      ),
      act: (bloc) => bloc.add(const WeatherStarted()),
      verify: (bloc) {
        expect(bloc.state.status, LoadStatus.ready);
        expect(bloc.state.place, UzbekCities.tashkent);
        expect(bloc.state.locationAccess, LocationAccess.denied);
        expect(bloc.state.needsLocationAccess, isTrue);
      },
    );

    blocTest<WeatherBloc, WeatherState>(
      'refused location outside the known regions still shows Tashkent',
      build: () => build(
        weather: FakeWeatherRepository(
          result: Right<DataFailure, Forecast>(forecast),
        ),
        location: FakeLocationRepository(
          region: 'DE',
          access: LocationAccess.denied,
        ),
      ),
      act: (bloc) => bloc.add(const WeatherStarted()),
      verify: (bloc) {
        expect(bloc.state.status, LoadStatus.ready);
        expect(bloc.state.place, UzbekCities.tashkent);
      },
    );

    blocTest<WeatherBloc, WeatherState>(
      'location switched off never blocks a saved place',
      build: () => build(
        weather: FakeWeatherRepository(
          result: Right<DataFailure, Forecast>(forecast),
        ),
        location: FakeLocationRepository(
          selected: UzbekCities.tashkent,
          access: LocationAccess.servicesOff,
        ),
      ),
      act: (bloc) => bloc.add(const WeatherStarted()),
      verify: (bloc) {
        expect(bloc.state.status, LoadStatus.ready);
        expect(bloc.state.forecast, forecast);
        expect(bloc.state.locationAccess, LocationAccess.servicesOff);
      },
    );

    final located = UzbekCities.regionalCentres[1];
    late FakeLocationRepository returning;
    blocTest<WeatherBloc, WeatherState>(
      'coming back with location allowed switches to the device position',
      setUp: () => returning = FakeLocationRepository(
        selected: UzbekCities.tashkent,
        access: LocationAccess.servicesOff,
      ),
      build: () => build(
        weather: FakeWeatherRepository(
          result: Right<DataFailure, Forecast>(forecast),
        ),
        location: returning,
      ),
      act: (bloc) async {
        bloc.add(const WeatherStarted());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        returning
          ..access = LocationAccess.granted
          ..locateResult = Right<DataFailure, Place>(located);
        bloc.add(const WeatherAppResumed());
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.locationAccess, LocationAccess.granted);
        expect(bloc.state.needsLocationAccess, isFalse);
        expect(bloc.state.place, located);
      },
    );

    blocTest<WeatherBloc, WeatherState>(
      'choosing a city loads it once, not twice',
      build: () => build(
        weather: FakeWeatherRepository(
          result: Right<DataFailure, Forecast>(forecast),
        ),
        location: FakeLocationRepository(selected: UzbekCities.tashkent),
      ),
      act: (bloc) =>
          bloc.add(WeatherPlaceSelected(UzbekCities.regionalCentres[1])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.place, UzbekCities.regionalCentres[1]);
      },
    );
  });
}
