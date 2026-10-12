import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/metric_tile.dart';

enum QuickDestination { prayer, field, route, alerts, photo, chat }

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key, required this.tint, required this.onOpen});

  final Color tint;
  final ValueChanged<QuickDestination> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(QuickDestination, IconData, String)>[
      (QuickDestination.prayer, LucideIcons.moon, l10n.quickPrayer),
      (QuickDestination.field, LucideIcons.wheat, l10n.quickField),
      (QuickDestination.route, LucideIcons.milestone, l10n.quickRoute),
      (QuickDestination.alerts, LucideIcons.alertTriangle, l10n.quickAlerts),
      (QuickDestination.photo, LucideIcons.camera, l10n.quickPhoto),
      (QuickDestination.chat, LucideIcons.messageCircle, l10n.quickChat),
    ];
    return TileGrid(
      children: <Widget>[
        for (final (destination, icon, label) in items)
          GlassPanel(
            radius: OsmonRadius.md,
            padding: const EdgeInsets.symmetric(
              horizontal: OsmonSpace.s12,
              vertical: OsmonSpace.s14,
            ),
            semanticLabel: label,
            onTap: () => onOpen(destination),
            child: Row(
              children: <Widget>[
                Icon(icon, size: OsmonSize.iconMd, color: tint),
                const SizedBox(width: OsmonSpace.s10),
                Expanded(
                  child: Text(
                    label,
                    style: OsmonType.captionStrong,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: OsmonSize.iconSm,
                  color: OsmonColors.textTertiary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
