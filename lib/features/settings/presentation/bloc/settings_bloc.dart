import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/units.dart';
import '../../domain/app_settings.dart';
import '../../domain/notification_permissions.dart';
import '../../domain/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// App-scoped: units, language and the live-sky switches are read by every
/// screen, so this Bloc lives for the whole session (registered as a lazy
/// singleton) and mirrors writes made elsewhere, e.g. by onboarding.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._repository, this._permissions)
    : super(SettingsState(settings: _repository.current)) {
    on<SettingsLanguageSelected>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(languageCode: event.code)),
    );
    on<SettingsTemperatureUnitSelected>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(temperatureUnit: event.unit)),
    );
    on<SettingsWindUnitSelected>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(windUnit: event.unit)),
    );
    on<SettingsPressureUnitSelected>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(pressureUnit: event.unit)),
    );
    on<SettingsLiveBackgroundToggled>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(liveBackground: event.enabled)),
    );
    on<SettingsBatterySaverToggled>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(batterySaver: event.enabled)),
    );
    on<SettingsReduceMotionToggled>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(reduceMotion: event.enabled)),
    );
    on<SettingsPrayerMethodSelected>(
      (event, emit) =>
          _save(emit, state.settings.copyWith(prayerMethod: event.method)),
    );
    on<SettingsNotificationToggled>(
      _onNotificationToggled,
      transformer: droppable(),
    );
    on<SettingsNotificationSettingsOpened>(
      (event, emit) => _permissions.openSettings(),
      transformer: droppable(),
    );
    on<_SettingsChangedElsewhere>(
      (event, emit) => emit(state.copyWith(settings: event.settings)),
    );
    _subscription = _repository.watch().listen(
      (settings) => add(_SettingsChangedElsewhere(settings)),
    );
  }

  final SettingsRepository _repository;
  final NotificationPermissions _permissions;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> _save(Emitter<SettingsState> emit, AppSettings settings) async {
    emit(state.copyWith(settings: settings));
    await _repository.save(settings);
  }

  Future<void> _onNotificationToggled(
    SettingsNotificationToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (event.enabled && !await _permissions.request()) {
      emit(
        state.copyWith(
          permissionDeniedNotice: state.permissionDeniedNotice + 1,
        ),
      );
      return;
    }
    final kinds = Set<NotificationKind>.of(state.settings.notifications);
    event.enabled ? kinds.add(event.kind) : kinds.remove(event.kind);
    await _save(emit, state.settings.copyWith(notifications: kinds));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
