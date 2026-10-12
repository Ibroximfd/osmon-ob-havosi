import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/place.dart';
import '../../domain/favorites_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

/// App-scoped: the star on the home header and the search list share it.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(this._repository)
    : super(FavoritesState(places: _repository.all)) {
    on<FavoriteToggled>(
      (event, emit) => _repository.toggle(event.place),
      transformer: sequential(),
    );
    on<_FavoritesChanged>(
      (event, emit) => emit(FavoritesState(places: event.places)),
    );
    _subscription = _repository.watch().listen(
      (places) => add(_FavoritesChanged(places)),
    );
  }

  final FavoritesRepository _repository;
  late final StreamSubscription<List<Place>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
