part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class SettingsLanguageSelected extends SettingsEvent {
  const SettingsLanguageSelected(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

final class SettingsTemperatureUnitSelected extends SettingsEvent {
  const SettingsTemperatureUnitSelected(this.unit);

  final TemperatureUnit unit;

  @override
  List<Object?> get props => <Object?>[unit];
}

final class SettingsWindUnitSelected extends SettingsEvent {
  const SettingsWindUnitSelected(this.unit);

  final WindUnit unit;

  @override
  List<Object?> get props => <Object?>[unit];
}

final class SettingsPressureUnitSelected extends SettingsEvent {
  const SettingsPressureUnitSelected(this.unit);

  final PressureUnit unit;

  @override
  List<Object?> get props => <Object?>[unit];
}

final class SettingsLiveBackgroundToggled extends SettingsEvent {
  const SettingsLiveBackgroundToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

final class SettingsBatterySaverToggled extends SettingsEvent {
  const SettingsBatterySaverToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

final class SettingsReduceMotionToggled extends SettingsEvent {
  const SettingsReduceMotionToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

final class SettingsPrayerMethodSelected extends SettingsEvent {
  const SettingsPrayerMethodSelected(this.method);

  final PrayerMethod method;

  @override
  List<Object?> get props => <Object?>[method];
}

final class SettingsNotificationToggled extends SettingsEvent {
  const SettingsNotificationToggled(this.kind, {required this.enabled});

  final NotificationKind kind;
  final bool enabled;

  @override
  List<Object?> get props => <Object?>[kind, enabled];
}

/// The user chose to fix a refused notification permission in the system
/// settings.
final class SettingsNotificationSettingsOpened extends SettingsEvent {
  const SettingsNotificationSettingsOpened();
}

final class _SettingsChangedElsewhere extends SettingsEvent {
  const _SettingsChangedElsewhere(this.settings);

  final AppSettings settings;

  @override
  List<Object?> get props => <Object?>[settings];
}
