import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/error/data_failure.dart';
import '../../../location/domain/location_repository.dart';
import '../../domain/field_advisor.dart';
import '../../domain/field_conditions.dart';
import '../../domain/field_repository.dart';

part 'field_event.dart';
part 'field_state.dart';

class FieldBloc extends Bloc<FieldEvent, FieldState> {
  FieldBloc(this._repository, this._location)
    : super(FieldState(crop: _repository.savedCrop)) {
    on<FieldRequested>(_onRequested, transformer: restartable());
    on<FieldCropSelected>(_onCropSelected);
    _subscription = _location.watchSelectedPlace().listen(
      (_) => add(const FieldRequested()),
    );
  }

  final FieldRepository _repository;
  final LocationRepository _location;
  late final StreamSubscription<Place> _subscription;

  Future<void> _onRequested(
    FieldRequested event,
    Emitter<FieldState> emit,
  ) async {
    final place = _location.selectedPlace;
    if (place == null) {
      emit(FieldState(status: LoadStatus.empty, crop: state.crop));
      return;
    }
    emit(
      FieldState(status: LoadStatus.loading, crop: state.crop, place: place),
    );
    final result = await _repository.loadConditions(place);
    result.fold(
      (failure) => emit(
        FieldState(
          status: failure is OfflineFailure
              ? LoadStatus.offline
              : LoadStatus.failure,
          crop: state.crop,
          place: place,
          failure: failure,
        ),
      ),
      (conditions) => emit(
        FieldState(
          status: LoadStatus.ready,
          crop: state.crop,
          place: place,
          conditions: conditions,
        ),
      ),
    );
  }

  Future<void> _onCropSelected(
    FieldCropSelected event,
    Emitter<FieldState> emit,
  ) async {
    emit(state.copyWith(crop: event.crop));
    await _repository.saveCrop(event.crop);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
