import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/error/data_failure.dart';
import '../../../../core/theme/osmon_motion.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/place_search_repository.dart';

part 'place_search_event.dart';
part 'place_search_state.dart';

class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState> {
  PlaceSearchBloc(
    this._repository,
    this._settings, {
    Duration debounce = OsmonMotion.searchDebounce,
  }) : super(const PlaceSearchState()) {
    on<PlaceQueryChanged>(
      _onQueryChanged,
      // Debounce keystrokes, then let the newest request cancel older ones.
      transformer: (events, mapper) =>
          restartable<PlaceQueryChanged>()(events.debounce(debounce), mapper),
    );
  }

  final PlaceSearchRepository _repository;
  final SettingsRepository _settings;

  static const int _minQueryLength = 2;

  Future<void> _onQueryChanged(
    PlaceQueryChanged event,
    Emitter<PlaceSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < _minQueryLength) {
      emit(PlaceSearchState(query: query));
      return;
    }
    emit(PlaceSearchState(query: query, status: LoadStatus.loading));
    final result = await _repository.search(
      query,
      languageCode: _settings.current.languageCode ?? 'uz',
    );
    result.fold(
      (failure) => emit(
        PlaceSearchState(
          query: query,
          status: failure is OfflineFailure
              ? LoadStatus.offline
              : LoadStatus.failure,
          failure: failure,
        ),
      ),
      (places) => emit(
        PlaceSearchState(
          query: query,
          status: LoadStatus.ready,
          results: places,
        ),
      ),
    );
  }
}
