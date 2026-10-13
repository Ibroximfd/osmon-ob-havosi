import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/units.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/app_settings.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/notification_permissions.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/presentation/bloc/settings_bloc.dart';

import '../../helpers/fakes.dart';

/// Starts blocked; [request] grants only when [grantsOnRequest].
final class _RecordingPermissions implements NotificationPermissions {
  _RecordingPermissions({this.grantsOnRequest = false});

  final bool grantsOnRequest;
  bool _granted = false;
  int settingsOpened = 0;

  @override
  Future<bool> request() async => _granted = grantsOnRequest;

  @override
  Future<bool> isGranted() async => _granted;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

void main() {
  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'a unit change is saved',
      build: () => SettingsBloc(
        FakeSettingsRepository(),
        const FakePermissions(granted: true),
      ),
      act: (bloc) => bloc.add(
        const SettingsPressureUnitSelected(PressureUnit.millimetreMercury),
      ),
      verify: (bloc) => expect(
        bloc.state.settings.pressureUnit,
        PressureUnit.millimetreMercury,
      ),
    );

    blocTest<SettingsBloc, SettingsState>(
      'enabling a notification the OS refuses leaves it off and raises a notice',
      build: () => SettingsBloc(
        FakeSettingsRepository(
          const AppSettings(
            languageCode: 'uz',
            notifications: <NotificationKind>{},
          ),
        ),
        const FakePermissions(granted: false),
      ),
      act: (bloc) => bloc.add(
        const SettingsNotificationToggled(
          NotificationKind.prayer,
          enabled: true,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.permissionDeniedNotice, 1);
        expect(bloc.state.settings.isEnabled(NotificationKind.prayer), isFalse);
        expect(bloc.state.isNotificationOn(NotificationKind.prayer), isFalse);
      },
    );

    final permissions = _RecordingPermissions();
    blocTest<SettingsBloc, SettingsState>(
      'a refused permission can be fixed from the system settings',
      build: () => SettingsBloc(FakeSettingsRepository(), permissions),
      act: (bloc) => bloc.add(const SettingsNotificationSettingsOpened()),
      verify: (_) => expect(permissions.settingsOpened, 1),
    );

    blocTest<SettingsBloc, SettingsState>(
      'a phone that blocks notifications shows the saved switches as off',
      build: () => SettingsBloc(
        FakeSettingsRepository(),
        const FakePermissions(granted: false),
      ),
      verify: (bloc) {
        expect(bloc.state.notificationsAllowed, isFalse);
        expect(
          bloc.state.settings.isEnabled(NotificationKind.dailySummary),
          isTrue,
        );
        expect(
          bloc.state.isNotificationOn(NotificationKind.dailySummary),
          isFalse,
        );
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'allowing from the notice brings the saved switches back',
      build: () => SettingsBloc(
        FakeSettingsRepository(),
        _RecordingPermissions(grantsOnRequest: true),
      ),
      act: (bloc) => bloc.add(const SettingsNotificationsAllowRequested()),
      verify: (bloc) {
        expect(bloc.state.notificationsAllowed, isTrue);
        expect(bloc.state.isNotificationOn(NotificationKind.rainSoon), isTrue);
        expect(bloc.state.permissionDeniedNotice, 0);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'granting turns every kind of notification on',
      build: () => SettingsBloc(
        FakeSettingsRepository(
          const AppSettings(
            languageCode: 'uz',
            notifications: <NotificationKind>{NotificationKind.rainSoon},
          ),
        ),
        _RecordingPermissions(grantsOnRequest: true),
      ),
      act: (bloc) => bloc.add(const SettingsNotificationsAllowRequested()),
      verify: (bloc) {
        for (final kind in NotificationKind.values) {
          expect(bloc.state.isNotificationOn(kind), isTrue, reason: '$kind');
        }
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'entering the app asks again while notifications are blocked',
      build: () => SettingsBloc(
        FakeSettingsRepository(),
        _RecordingPermissions(grantsOnRequest: true),
      ),
      act: (bloc) => bloc.add(const SettingsMainScreenShown()),
      verify: (bloc) {
        expect(bloc.state.notificationsAllowed, isTrue);
        expect(bloc.state.isNotificationOn(NotificationKind.prayer), isTrue);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'a refusal on entry shows no snackbar, only the notice',
      build: () =>
          SettingsBloc(FakeSettingsRepository(), _RecordingPermissions()),
      act: (bloc) => bloc.add(const SettingsMainScreenShown()),
      verify: (bloc) {
        expect(bloc.state.notificationsAllowed, isFalse);
        expect(bloc.state.permissionDeniedNotice, 0);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'a refusal from the notice offers the system settings',
      build: () =>
          SettingsBloc(FakeSettingsRepository(), _RecordingPermissions()),
      act: (bloc) => bloc.add(const SettingsNotificationsAllowRequested()),
      verify: (bloc) {
        expect(bloc.state.notificationsAllowed, isFalse);
        expect(bloc.state.permissionDeniedNotice, 1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'disabling never asks for permission',
      build: () => SettingsBloc(
        FakeSettingsRepository(),
        const FakePermissions(granted: false),
      ),
      act: (bloc) => bloc.add(
        const SettingsNotificationToggled(
          NotificationKind.rainSoon,
          enabled: false,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.permissionDeniedNotice, 0);
        expect(
          bloc.state.settings.isEnabled(NotificationKind.rainSoon),
          isFalse,
        );
      },
    );
  });
}
