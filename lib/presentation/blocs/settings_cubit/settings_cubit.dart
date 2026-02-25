import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── State ─────────────────────────────────────────────────────────────────

class SettingsState {
  final String tempUnit; // 'C' | 'F'
  final String windUnit; // 'km/h' | 'm/s'
  final String selectedCity;

  const SettingsState({
    this.tempUnit = 'C',
    this.windUnit = 'km/h',
    this.selectedCity = 'Toshkent',
  });

  SettingsState copyWith({
    String? tempUnit,
    String? windUnit,
    String? selectedCity,
  }) {
    return SettingsState(
      tempUnit: tempUnit ?? this.tempUnit,
      windUnit: windUnit ?? this.windUnit,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }
}

// ─── Cubit ─────────────────────────────────────────────────────────────────

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  static const _keyTempUnit = 'settings_temp_unit';
  static const _keyWindUnit = 'settings_wind_unit';
  static const _keyCity = 'settings_city';

  SettingsCubit(this._prefs) : super(_loadFromPrefs(_prefs));

  static SettingsState _loadFromPrefs(SharedPreferences prefs) {
    return SettingsState(
      tempUnit: prefs.getString(_keyTempUnit) ?? 'C',
      windUnit: prefs.getString(_keyWindUnit) ?? 'km/h',
      selectedCity: prefs.getString(_keyCity) ?? 'Toshkent',
    );
  }

  Future<void> setTempUnit(String unit) async {
    await _prefs.setString(_keyTempUnit, unit);
    emit(state.copyWith(tempUnit: unit));
  }

  Future<void> setWindUnit(String unit) async {
    await _prefs.setString(_keyWindUnit, unit);
    emit(state.copyWith(windUnit: unit));
  }

  Future<void> setSelectedCity(String city) async {
    await _prefs.setString(_keyCity, city);
    emit(state.copyWith(selectedCity: city));
  }
}
