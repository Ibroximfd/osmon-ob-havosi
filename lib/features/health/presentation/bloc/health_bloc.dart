import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/error/data_failure.dart';
import '../../../location/domain/location_repository.dart';
import '../../domain/air_quality.dart';
import '../../domain/air_quality_repository.dart';
import '../../domain/health_assessment.dart';

part 'health_event.dart';
part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc(this._repository, this._location) : super(const HealthState()) {
    on<HealthRequested>(_onRequested, transformer: restartable());
    _subscription = _location.watchSelectedPlace().listen(
      (_) => add(const HealthRequested()),
    );
  }

  final AirQualityRepository _repository;
  final LocationRepository _location;
  late final StreamSubscription<Place> _subscription;

  Future<void> _onRequested(
    HealthRequested event,
    Emitter<HealthState> emit,
  ) async {
    final place = _location.selectedPlace;
    if (place == null) {
      emit(const HealthState(status: LoadStatus.empty));
      return;
    }
    emit(HealthState(status: LoadStatus.loading, place: place));
    final result = await _repository.loadReport(place);
    result.fold(
      (failure) => emit(
        HealthState(
          status: failure is OfflineFailure
              ? LoadStatus.offline
              : LoadStatus.failure,
          place: place,
          failure: failure,
        ),
      ),
      (report) => emit(
        HealthState(status: LoadStatus.ready, place: place, report: report),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
