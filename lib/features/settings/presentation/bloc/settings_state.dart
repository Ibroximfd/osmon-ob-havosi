part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
    this.permissionDeniedNotice = 0,
    this.notificationsAllowed = true,
  });

  final AppSettings settings;

  /// Whether the OS lets the app post notifications. Optimistic until the
  /// first check, so the "blocked" notice never flashes on a granted phone.
  final bool notificationsAllowed;

  /// What a toggle shows: a kind the user enabled still delivers nothing
  /// while the OS blocks the app, so it reads as off.
  bool isNotificationOn(NotificationKind kind) =>
      notificationsAllowed && settings.isEnabled(kind);

  /// Increments each time a notification toggle was refused by the OS, so a
  /// listener can show the hint once per refusal.
  final int permissionDeniedNotice;

  SettingsState copyWith({
    AppSettings? settings,
    int? permissionDeniedNotice,
    bool? notificationsAllowed,
  }) => SettingsState(
    settings: settings ?? this.settings,
    permissionDeniedNotice:
        permissionDeniedNotice ?? this.permissionDeniedNotice,
    notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
  );

  @override
  List<Object?> get props => <Object?>[
    settings,
    permissionDeniedNotice,
    notificationsAllowed,
  ];
}
