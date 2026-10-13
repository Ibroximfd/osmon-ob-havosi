import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/error/data_failure.dart';
import '../../../../core/sky/sky_scene.dart';
import '../../../ai/domain/ai_repository.dart';
import '../../../location/domain/capital_fallback.dart';
import '../../../location/domain/location_repository.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/services/day_story.dart';
import '../../domain/services/life_indices.dart';
import '../../domain/services/nowcast_outlook.dart';
import '../../domain/services/pressure_trend.dart';
import '../../domain/services/sky_of_forecast.dart';
import '../../domain/weather_repository.dart';

part 'weather_event.dart';
part 'weather_state.dart';

/// App-scoped (lazy singleton): the home screen, the sky behind every page,
/// the widget sync and several feature screens all read the current place's
/// forecast, so it is loaded once and shared.
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({
    required WeatherRepository weather,
    required LocationRepository location,
    required SettingsRepository settings,
    required AiRepository ai,
  }) : _weather = weather,
       _location = location,
       _settings = settings,
       _ai = ai,
       super(const WeatherState()) {
    on<WeatherLoadEvent>(_onLoad, transformer: restartable());
    on<WeatherLocationSettingsOpened>(
      (event, emit) => _location.openLocationSettings(
        servicesDisabled: state.locationAccess == LocationAccess.servicesOff,
      ),
    );
    on<WeatherAppResumed>(_onResumed, transformer: droppable());
    _placeSubscription = _location.watchSelectedPlace().listen((place) {
      // Selections this Bloc made itself are already loading.
      if (place != _selecting) add(_SelectedPlaceChanged(place));
    });
  }

  final WeatherRepository _weather;
  final LocationRepository _location;
  final SettingsRepository _settings;
  final AiRepository _ai;
  late final StreamSubscription<Place> _placeSubscription;
  Place? _selecting;

  /// Below this the device is still "here": a new fix only shifts the
  /// coordinates within the same town.
  static const double _movedKm = 3;

  String get _language => _settings.current.languageCode ?? 'uz';

  Future<void> _onLoad(
    WeatherLoadEvent event,
    Emitter<WeatherState> emit,
  ) async {
    switch (event) {
      case WeatherStarted():
        await _start(emit);
      case WeatherRefreshed():
        final place = state.place;
        if (place != null) await _load(place, emit, isRefresh: true);
      case WeatherPlaceSelected(:final place):
        await _select(place);
        await _load(place, emit);
      case _SelectedPlaceChanged(:final place):
        await _load(place, emit);
      case WeatherLocateRequested():
        await _locate(emit, prompt: true);
    }
  }

  Future<void> _start(Emitter<WeatherState> emit) async {
    final selected = _location.selectedPlace;
    if (selected != null) {
      final access = await _location.checkAccess();
      emit(state.copyWith(locationAccess: access));
      await _load(selected, emit);
      if (selected.isCurrentLocation && access == LocationAccess.granted) {
        await _followDevice(selected, emit);
      }
      return;
    }
    await _locate(emit, prompt: false);
  }

  /// A saved GPS place goes stale when the user travels. It is shown first,
  /// then the device is located quietly and the app switches only on a real
  /// move, not on GPS jitter.
  Future<void> _followDevice(Place saved, Emitter<WeatherState> emit) async {
    final result = await _location.locateDevice(
      languageCode: _language,
      prompt: false,
    );
    final here = result.fold((_) => null, (place) => place);
    if (here == null || emit.isDone) return;
    if (here.point.distanceKmTo(saved.point) < _movedKm) return;
    await _select(here);
    await _load(here, emit);
  }

  /// Picks up access granted (or revoked) in the system settings. The
  /// permission dialog itself also pauses the app, so a locate already in
  /// flight is left to finish on its own.
  Future<void> _onResumed(
    WeatherAppResumed event,
    Emitter<WeatherState> emit,
  ) async {
    final before = state.locationAccess;
    if (before == null || state.isLocating) return;
    final access = await _location.checkAccess();
    if (access == before) return;
    emit(state.copyWith(locationAccess: access));
    if (access == LocationAccess.granted) add(const WeatherLocateRequested());
  }

  Future<void> _locate(
    Emitter<WeatherState> emit, {
    required bool prompt,
  }) async {
    emit(state.copyWith(isLocating: true));
    final result = await _location.locateDevice(
      languageCode: _language,
      prompt: prompt,
    );
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isLocating: false,
            locationAccess: await _location.checkAccess(),
          ),
        );
        if (state.place != null) return;
        final fallback = capitalFor(_location.deviceRegionCode());
        await _select(fallback);
        await _load(fallback, emit);
      },
      (place) async {
        emit(
          state.copyWith(
            isLocating: false,
            locationAccess: LocationAccess.granted,
          ),
        );
        await _select(place);
        await _load(place, emit);
      },
    );
  }

  Future<void> _select(Place place) {
    _selecting = place;
    return _location.selectPlace(place);
  }

  Future<void> _load(
    Place place,
    Emitter<WeatherState> emit, {
    bool isRefresh = false,
  }) async {
    final keepsContent = isRefresh && state.forecast != null;
    emit(
      keepsContent
          ? state.copyWith(isRefreshing: true)
          : WeatherState(
              status: LoadStatus.loading,
              place: place,
              locationAccess: state.locationAccess,
            ),
    );

    final result = await _weather.loadForecast(place);
    final forecast = result.fold((_) => null, (value) => value);
    if (forecast == null) {
      final failure = result.fold((f) => f, (_) => const ServerFailure());
      await _fail(place, failure, emit, keepsContent: keepsContent);
      return;
    }
    emit(
      WeatherState(
        status: LoadStatus.ready,
        place: place,
        forecast: forecast,
        locationAccess: state.locationAccess,
        pastDay: keepsContent ? state.pastDay : null,
        aiStory: keepsContent ? state.aiStory : null,
      ),
    );
    await _enrich(forecast, emit);
  }

  Future<void> _fail(
    Place place,
    DataFailure failure,
    Emitter<WeatherState> emit, {
    required bool keepsContent,
  }) async {
    if (keepsContent) {
      emit(state.copyWith(isRefreshing: false, failure: failure));
      return;
    }
    final cached = failure is OfflineFailure
        ? await _weather.readCachedForecast(place)
        : null;
    emit(
      WeatherState(
        status: failure is OfflineFailure
            ? LoadStatus.offline
            : LoadStatus.failure,
        place: place,
        forecast: cached,
        failure: failure,
        locationAccess: state.locationAccess,
      ),
    );
  }

  /// Secondary content after the forecast is on screen: last year's
  /// temperature and the AI story. Their failures are silent — the local
  /// story already covers the same ground.
  Future<void> _enrich(Forecast forecast, Emitter<WeatherState> emit) async {
    final today = forecast.today?.date ?? forecast.fetchedAt;
    final past = await _weather.loadSameDayLastYear(forecast.place, today);
    past.fold((_) {}, (day) => emit(state.copyWith(pastDay: day)));

    if (!_ai.isConfigured || emit.isDone) return;
    final story = await _ai.writeDayStory(forecast, languageCode: _language);
    story.fold((_) {}, (text) {
      if (!emit.isDone) emit(state.copyWith(aiStory: text));
    });
  }

  @override
  Future<void> close() {
    _placeSubscription.cancel();
    return super.close();
  }
}
