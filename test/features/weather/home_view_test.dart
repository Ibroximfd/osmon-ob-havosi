import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/bloc/load_status.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/error/data_failure.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/widgets/state_views.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/favorites/domain/favorites_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/location/domain/location_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/domain/entities/forecast.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/widgets/hero_conditions.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/widgets/home_empty_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/widgets/home_skeleton.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/widgets/home_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/l10n/app_localizations.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/time/tz_time_zone_resolver.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/data/adhan_prayer_times_source.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/presentation/bloc/prayer_bloc.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../helpers/fakes.dart';
import '../../helpers/forecast_fixture.dart';

/// A real WeatherBloc whose state the test sets directly.
final class _SeededWeatherBloc extends WeatherBloc {
  _SeededWeatherBloc(WeatherState initial)
    : super(
        weather: FakeWeatherRepository(
          result: const Left<DataFailure, Forecast>(OfflineFailure()),
        ),
        location: FakeLocationRepository(selected: UzbekCities.tashkent),
        settings: FakeSettingsRepository(),
        ai: const FakeAiRepository(),
      ) {
    emit(initial);
  }

  final List<WeatherEvent> received = <WeatherEvent>[];

  @override
  void add(WeatherEvent event) => received.add(event);
}

final class _NoFavorites implements FavoritesRepository {
  @override
  List<Place> get all => const <Place>[];

  @override
  Future<void> toggle(Place place) async {}

  @override
  Stream<List<Place>> watch() => const Stream<List<Place>>.empty();
}

Future<_SeededWeatherBloc> _pump(
  WidgetTester tester,
  WeatherState state,
) async {
  final weather = _SeededWeatherBloc(state);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<WeatherBloc>.value(value: weather),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(
            FakeSettingsRepository(),
            const FakePermissions(granted: true),
          ),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(_NoFavorites()),
        ),
        BlocProvider<PrayerBloc>(
          create: (_) => PrayerBloc(
            location: FakeLocationRepository(selected: UzbekCities.tashkent),
            settings: FakeSettingsRepository(),
            times: const AdhanPrayerTimesSource(),
            timeZones: const TzTimeZoneResolver(),
            // 14:06 in Tashkent: dhuhr has passed, asr is next.
            clock: () => DateTime.utc(2026, 10, 12, 9, 6),
            tick: const Duration(days: 1),
          )..add(const PrayerStarted()),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('uz'),
        home: Scaffold(body: HomeView()),
      ),
    ),
  );
  // Let staggered reveals and their timers finish without settling the
  // endlessly animating weather glyph.
  await tester.pump(const Duration(seconds: 2));
  return weather;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('loading shows the skeleton', (tester) async {
    await _pump(tester, const WeatherState(status: LoadStatus.loading));
    expect(find.byType(HomeSkeleton), findsOneWidget);
  });

  testWidgets('no place shows the empty view with both actions', (
    tester,
  ) async {
    await _pump(tester, const WeatherState(status: LoadStatus.empty));
    expect(find.byType(HomeEmptyView), findsOneWidget);
  });

  testWidgets('a failure offers a retry that reloads', (tester) async {
    final bloc = await _pump(
      tester,
      WeatherState(
        status: LoadStatus.failure,
        place: UzbekCities.tashkent,
        failure: const ServerFailure('HTTP 500'),
      ),
    );
    expect(find.byType(ErrorStateView), findsOneWidget);
    await tester.tap(find.text('Qayta urinish'));
    expect(bloc.received.single, isA<WeatherRefreshed>());
  });

  testWidgets('offline keeps the cached forecast under a neutral banner', (
    tester,
  ) async {
    await _pump(
      tester,
      WeatherState(
        status: LoadStatus.offline,
        place: UzbekCities.tashkent,
        forecast: buildForecast(),
        failure: const OfflineFailure(),
      ),
    );
    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.byType(HeroConditions), findsOneWidget);
  });

  testWidgets('ready shows the hero temperature', (tester) async {
    await _pump(
      tester,
      WeatherState(
        status: LoadStatus.ready,
        place: UzbekCities.tashkent,
        forecast: buildForecast(temperature: 23),
      ),
    );
    expect(find.byType(HeroConditions), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.byType(OfflineBanner), findsNothing);
    expect(find.byType(LocationHintCard), findsNothing);
  });

  testWidgets('the next prayer and the road forecast sit near the top', (
    tester,
  ) async {
    await _pump(
      tester,
      WeatherState(
        status: LoadStatus.ready,
        place: UzbekCities.tashkent,
        forecast: buildForecast(),
      ),
    );
    expect(find.text('KEYINGI NAMOZ'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.text("YO'L OB-HAVOSI"), findsOneWidget);
  });

  testWidgets('refused location asks for it above a working forecast', (
    tester,
  ) async {
    final bloc = await _pump(
      tester,
      WeatherState(
        status: LoadStatus.ready,
        place: UzbekCities.tashkent,
        forecast: buildForecast(),
        locationAccess: LocationAccess.denied,
      ),
    );
    expect(find.byType(LocationHintCard), findsOneWidget);
    expect(find.byType(HeroConditions), findsOneWidget);
    await tester.tap(find.text('Ruxsat berish'));
    expect(bloc.received.single, isA<WeatherLocateRequested>());
  });

  testWidgets('location switched off sends the user to the system switch', (
    tester,
  ) async {
    final bloc = await _pump(
      tester,
      WeatherState(
        status: LoadStatus.ready,
        place: UzbekCities.tashkent,
        forecast: buildForecast(),
        locationAccess: LocationAccess.servicesOff,
      ),
    );
    expect(find.text("Joylashuv o'chiq"), findsOneWidget);
    await tester.tap(find.text('Yoqish'));
    expect(bloc.received.single, isA<WeatherLocationSettingsOpened>());
  });
}
