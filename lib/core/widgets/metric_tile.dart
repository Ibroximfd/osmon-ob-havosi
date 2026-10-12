import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';
import 'glass_panel.dart';

/// Label · big value · one line of meaning. Used in 2-column grids.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;

  /// Colours the value when it carries a severity.
  final Color? accent;

  @override
  Widget build(BuildContext context) => GlassPanel(
    radius: OsmonRadius.md,
    padding: const EdgeInsets.all(OsmonSpace.s12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: OsmonSize.iconSm,
                color: OsmonColors.textTertiary,
              ),
              const SizedBox(width: OsmonSpace.s6),
            ],
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: OsmonType.eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: OsmonSpace.s6),
        Text(
          value,
          style: OsmonType.numberMedium.copyWith(color: accent),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (caption != null) ...<Widget>[
          const SizedBox(height: OsmonSpace.s2),
          Text(
            caption!,
            style: OsmonType.caption.copyWith(color: OsmonColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    ),
  );
}

/// Lays tiles out two per row with equal heights per row.
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children, this.columns = 2});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        if (c > 0) cells.add(const SizedBox(width: OsmonSpace.s8));
        final index = i + c;
        cells.add(
          Expanded(
            child: index < children.length
                ? children[index]
                : const SizedBox.shrink(),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: OsmonSpace.s8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
