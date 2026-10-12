import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/osmon_colors.dart';
import '../../core/theme/osmon_motion.dart';
import '../../core/theme/osmon_spacing.dart';
import '../../core/theme/osmon_typography.dart';
import '../../core/widgets/glass_panel.dart';

/// Floating glass tab bar. The active tab's icon lifts and takes the
/// scene's tint, so the bar quietly follows the weather too.
class OsmonNavBar extends StatelessWidget {
  const OsmonNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.tint,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <({IconData icon, String label})>[
      (icon: LucideIcons.home, label: l10n.navHome),
      (icon: LucideIcons.radar, label: l10n.navRadar),
      (icon: LucideIcons.map, label: l10n.navMap),
      (icon: LucideIcons.heartPulse, label: l10n.navHealth),
      (icon: LucideIcons.settings2, label: l10n.navSettings),
    ];
    return GlassPanel(
      blur: true,
      radius: OsmonRadius.xl,
      fill: OsmonColors.navBar,
      padding: const EdgeInsets.symmetric(horizontal: OsmonSpace.s6),
      child: SizedBox(
        height: OsmonSize.navBarHeight,
        child: Row(
          children: <Widget>[
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  selected: i == currentIndex,
                  tint: tint,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? OsmonColors.textPrimary : OsmonColors.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: OsmonSize.tapTarget,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSlide(
              offset: selected ? const Offset(0, -0.12) : Offset.zero,
              duration: OsmonMotion.base,
              curve: OsmonMotion.spring,
              child: AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: OsmonMotion.base,
                curve: OsmonMotion.spring,
                child: Icon(icon, size: OsmonSize.iconMd, color: color),
              ),
            ),
            const SizedBox(height: OsmonSpace.s2),
            Text(
              label,
              style: OsmonType.navLabel.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: OsmonSpace.s4),
            AnimatedContainer(
              duration: OsmonMotion.base,
              curve: OsmonMotion.emphasized,
              width: selected ? OsmonSpace.s16 : 0,
              height: OsmonSpace.s2 + 1,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(OsmonRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
