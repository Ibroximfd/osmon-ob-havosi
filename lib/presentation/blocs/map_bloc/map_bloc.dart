import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../../domain/entities/region_weather.dart';
import '../../../data/datasources/map_data_source.dart';

// --- Events ---
abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class LoadMapEvent extends MapEvent {
  const LoadMapEvent();
}

// --- States ---
abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<RegionWeather> regions;
  const MapLoaded(this.regions);
  @override
  List<Object?> get props => [regions];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class MapBloc extends Bloc<MapEvent, MapState> {
  final MapDataSource dataSource;
  final _log = Logger();

  MapBloc({required this.dataSource}) : super(MapInitial()) {
    on<LoadMapEvent>((event, emit) async {
      emit(MapLoading());
      _log.i('MapBloc: Barcha viloyatlar yuklanmoqda...');
      try {
        final regions = await dataSource.getAllRegionsWeather();
        _log.i('MapBloc: ${regions.length} ta viloyat yuklandi');
        emit(MapLoaded(regions));
      } catch (e, st) {
        _log.e('MapBloc: Xatolik', error: e, stackTrace: st);
        emit(MapError(e.toString()));
      }
    });
  }
}
