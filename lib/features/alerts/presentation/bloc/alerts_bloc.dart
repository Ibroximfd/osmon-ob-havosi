import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/error/data_failure.dart';
import '../../../location/domain/location_repository.dart';
import '../../domain/alerts_repository.dart';
import '../../domain/weather_alert.dart';

part 'alerts_event.dart';
part 'alerts_state.dart';

/// Sweeps Uzbekistan's regional centres plus the user's own place.
class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  AlertsBloc(this._repository, this._location) : super(const AlertsState()) {
    on<AlertsRequested>(_onRequested, transformer: restartable());
  }

  final AlertsRepository _repository;
  final LocationRepository _location;

  Future<void> _onRequested(
    AlertsRequested event,
    Emitter<AlertsState> emit,
  ) async {
    emit(const AlertsState(status: LoadStatus.loading));
    final own = _location.selectedPlace;
    final places = <Place>[
      if (own != null &&
          !UzbekCities.regionalCentres.any((p) => p.key == own.key))
        own,
      ...UzbekCities.regionalCentres,
    ];
    final result = await _repository.loadRegionDays(places);
    result.fold(
      (failure) => emit(
        AlertsState(
          status: failure is OfflineFailure
              ? LoadStatus.offline
              : LoadStatus.failure,
          failure: failure,
        ),
      ),
      (byPlace) {
        final alerts = <WeatherAlert>[
          for (final entry in byPlace.entries)
            for (final day in entry.value) ...alertsFor(entry.key, day),
        ]..sort(_bySeverityThenDay);
        emit(
          AlertsState(
            status: alerts.isEmpty ? LoadStatus.empty : LoadStatus.ready,
            alerts: alerts,
            ownPlace: own,
          ),
        );
      },
    );
  }

  static int _bySeverityThenDay(WeatherAlert a, WeatherAlert b) {
    final level = b.level.index.compareTo(a.level.index);
    return level != 0 ? level : a.day.compareTo(b.day);
  }
}
