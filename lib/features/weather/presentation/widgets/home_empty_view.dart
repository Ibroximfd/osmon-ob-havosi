import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/widgets/osmon_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../location/domain/location_repository.dart';

/// No place to show yet. The Bloc falls back to a capital when location is
/// refused, so this only covers a state with nothing selected at all.
class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({
    super.key,
    required this.onLocate,
    required this.onSearch,
    required this.isLocating,
  });

  final VoidCallback onLocate;
  final VoidCallback onSearch;
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(OsmonSpace.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MessageStateView(
                icon: LucideIcons.mapPin,
                title: l10n.homeEmptyTitle,
                message: l10n.homeEmptyMessage,
              ),
              OsmonButton(
                label: l10n.homeLocateAction,
                icon: LucideIcons.locate,
                expand: true,
                isBusy: isLocating,
                onPressed: onLocate,
              ),
              const SizedBox(height: OsmonSpace.s10),
              OsmonButton(
                label: l10n.homeSearchTooltip,
                icon: LucideIcons.search,
                expand: true,
                tone: OsmonButtonTone.glass,
                onPressed: onSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown above the content while the app cannot use the device position,
/// so the user knows why the city on screen may not be theirs — and fixes
/// it in one tap. The rest of the screen keeps working.
class LocationHintCard extends StatelessWidget {
  const LocationHintCard({
    super.key,
    required this.access,
    required this.cityName,
    required this.onEnable,
  });

  final LocationAccess access;
  final String cityName;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final servicesOff = access == LocationAccess.servicesOff;
    final blocked = access == LocationAccess.deniedForever;
    return Padding(
      padding: const EdgeInsets.only(top: OsmonSpace.s12),
      child: OfflineStyleNotice(
        icon: LucideIcons.navigationOff,
        title: servicesOff
            ? l10n.homeLocationOffTitle
            : l10n.homeLocationDeniedTitle,
        message: blocked
            ? l10n.homeLocationBlockedMessage(cityName)
            : l10n.homeLocationMessage(cityName),
        actionLabel: switch (access) {
          LocationAccess.servicesOff => l10n.homeLocationAction,
          LocationAccess.deniedForever => l10n.actionOpenSettings,
          LocationAccess.denied || LocationAccess.granted => l10n.actionAllow,
        },
        onAction: onEnable,
      ),
    );
  }
}
