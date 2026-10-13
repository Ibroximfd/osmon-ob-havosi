import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../bloc/settings_bloc.dart';

/// Shown above the notification switches while the OS blocks the app, so a
/// user who skipped the permission is asked again instead of never hearing
/// from the app.
class NotificationsBlockedNotice extends StatelessWidget {
  const NotificationsBlockedNotice({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsBloc, SettingsState, bool>(
        selector: (state) => state.notificationsAllowed,
        builder: (context, allowed) {
          if (allowed) return const SizedBox.shrink();
          final l10n = context.l10n;
          return Padding(
            padding: const EdgeInsets.only(bottom: OsmonSpace.s10),
            child: OfflineStyleNotice(
              icon: LucideIcons.bellOff,
              title: l10n.notifBlockedTitle,
              message: l10n.notifBlockedMessage,
              actionLabel: l10n.actionAllow,
              onAction: () => context.read<SettingsBloc>().add(
                const SettingsNotificationsAllowRequested(),
              ),
            ),
          );
        },
      );
}
