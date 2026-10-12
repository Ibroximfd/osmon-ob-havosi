import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/units.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/app_settings.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/notification_permissions.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/presentation/bloc/settings_bloc.dart';

import '../../helpers/fakes.dart';

final class _RecordingPermissions implements NotificationPermissions {
  int settingsOpened = 0;

  @override
  Future<bool> request() async => false;

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
        FakeSettingsRepository(),
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
