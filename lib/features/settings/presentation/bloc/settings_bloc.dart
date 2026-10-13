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
    on<SettingsNotificationAccessChecked>(
      (event, emit) async => _applyPermission(
        emit,
        await _permissions.isGranted(),
        reportRefusal: false,
      ),
      transformer: droppable(),
    );
    on<SettingsNotificationsAllowRequested>(
      (event, emit) async =>
          _applyPermission(emit, await _permissions.request()),
      transformer: droppable(),
    );
    on<SettingsMainScreenShown>(_onMainScreenShown, transformer: droppable());
    on<_SettingsChangedElsewhere>(
      (event, emit) => emit(state.copyWith(settings: event.settings)),
    );
    _subscription = _repository.watch().listen(
      (settings) => add(_SettingsChangedElsewhere(settings)),
    );
    add(const SettingsNotificationAccessChecked());
  }

  final SettingsRepository _repository;
  final NotificationPermissions _permissions;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> _save(Emitter<SettingsState> emit, AppSettings settings) async {
    emit(state.copyWith(settings: settings));
    await _repository.save(settings);
  }

  /// Granting turns every notification on — the user just agreed to hear
  /// from the app. A refusal the user made by hand raises the notice whose
  /// snackbar offers the system settings.
  Future<void> _applyPermission(
    Emitter<SettingsState> emit,
    bool granted, {
    bool reportRefusal = true,
  }) async {
    final newlyGranted = granted && !state.notificationsAllowed;
    emit(
      state.copyWith(
        notificationsAllowed: granted,
        permissionDeniedNotice: granted || !reportRefusal
            ? state.permissionDeniedNotice
            : state.permissionDeniedNotice + 1,
      ),
    );
    if (newlyGranted) {
      await _save(
        emit,
        state.settings.copyWith(notifications: NotificationKind.values.toSet()),
      );
    }
  }

  /// Entering the app asks again while the OS blocks notifications. Android
  /// shows its dialog until the user refuses twice; after that the request
  /// returns at once and the home notice points to the system settings.
  Future<void> _onMainScreenShown(
    SettingsMainScreenShown event,
    Emitter<SettingsState> emit,
  ) async {
    if (await _permissions.isGranted()) return _applyPermission(emit, true);
    await _applyPermission(
      emit,
      await _permissions.request(),
      reportRefusal: false,
    );
  }

  Future<void> _onNotificationToggled(
    SettingsNotificationToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (event.enabled) {
      final granted = await _permissions.request();
      await _applyPermission(emit, granted);
      if (!granted) return;
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
