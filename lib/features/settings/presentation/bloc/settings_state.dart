part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
    this.permissionDeniedNotice = 0,
  });

  final AppSettings settings;

  /// Increments each time a notification toggle was refused by the OS, so a
  /// listener can show the hint once per refusal.
  final int permissionDeniedNotice;

  SettingsState copyWith({
    AppSettings? settings,
    int? permissionDeniedNotice,
  }) => SettingsState(
    settings: settings ?? this.settings,
    permissionDeniedNotice:
        permissionDeniedNotice ?? this.permissionDeniedNotice,
  );

  @override
  List<Object?> get props => <Object?>[settings, permissionDeniedNotice];
}
