import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';

/// Selectable pill used for layers, crops, units and filters.
class OsmonChip extends StatelessWidget {
  const OsmonChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tint = OsmonColors.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color tint;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? tint.withValues(alpha: 0.32) : OsmonColors.glassFill,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? tint.withValues(alpha: 0.7)
              : OsmonColors.glassStroke,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: OsmonSpace.s40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: OsmonSpace.s14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: OsmonSize.iconSm),
                  const SizedBox(width: OsmonSpace.s6),
                ],
                Text(label, style: OsmonType.captionStrong),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Horizontally scrolling row of chips that bleeds to the screen edges.
class ChipStrip extends StatelessWidget {
  const ChipStrip({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: OsmonSpace.gutter),
    child: Row(
      children: <Widget>[
        for (var i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: OsmonSpace.s8),
          children[i],
        ],
      ],
    ),
  );
}
