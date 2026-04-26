import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/favorites_service.dart';
import '../../../domain/entities/city.dart';

class FavoritesCubit extends Cubit<List<City>> {
  final FavoritesService _service;

  FavoritesCubit(this._service) : super([]) {
    emit(_service.getCities());
  }

  Future<void> toggle(City city) async {
    if (_service.isFavorite(city.name)) {
      await _service.removeCity(city);
    } else {
      await _service.addCity(city);
    }
    emit(_service.getCities());
  }

  bool isFavorite(String cityName) => _service.isFavorite(cityName);
}
