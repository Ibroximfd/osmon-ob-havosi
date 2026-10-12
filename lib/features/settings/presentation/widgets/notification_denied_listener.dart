import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../bloc/settings_bloc.dart';

/// Explains a refused notification toggle and offers the system settings —
/// once the OS stops showing its dialog, that is the only way back.
class NotificationDeniedListener extends StatelessWidget {
  const NotificationDeniedListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            current.permissionDeniedNotice > previous.permissionDeniedNotice,
        listener: (context, state) {
          final l10n = context.l10n;
          final bloc = context.read<SettingsBloc>();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.permissionNotificationsDenied),
              action: SnackBarAction(
                label: l10n.actionOpenSettings,
                onPressed: () =>
                    bloc.add(const SettingsNotificationSettingsOpened()),
              ),
            ),
          );
        },
        child: child,
      );
}
