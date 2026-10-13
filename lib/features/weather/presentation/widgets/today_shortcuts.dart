import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/prayer_labels.dart';

/// The next prayer with its countdown, and the road forecast — the two
/// features people open daily, side by side near the top of home.
class TodayShortcuts extends StatelessWidget {
  const TodayShortcuts({
    super.key,
    required this.formats,
    required this.tint,
    required this.onPrayer,
    required this.onRoute,
  });

  final Formats formats;
  final Color tint;
  final VoidCallback onPrayer;
  final VoidCallback onRoute;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: OsmonSpace.s10),
    child: TileGrid(
      children: <Widget>[
        _NextPrayerTile(formats: formats, tint: tint, onTap: onPrayer),
        _RouteTile(tint: tint, onTap: onRoute),
      ],
    ),
  );
}

class _NextPrayerTile extends StatelessWidget {
  const _NextPrayerTile({
    required this.formats,
    required this.tint,
    required this.onTap,
  });

  final Formats formats;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final next = state.next;
        final until = state.untilNext;
        return _ShortcutTile(
          icon: LucideIcons.moon,
          label: l10n.prayerNext,
          tint: tint,
          semanticLabel: l10n.prayerTitle,
          onTap: onTap,
          title: next == null ? '—' : prayerName(l10n, next.key),
          value: next == null ? null : formats.time(next.value),
          caption: until == null
              ? l10n.prayerTitle
              : l10n.prayerRemaining(formats.duration(until)),
          captionColor: until == null ? null : tint,
        );
      },
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({required this.tint, required this.onTap});

  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ShortcutTile(
      icon: LucideIcons.milestone,
      label: l10n.quickRoute,
      tint: tint,
      semanticLabel: l10n.quickRoute,
      onTap: onTap,
      title: l10n.routeEmptyTitle,
      caption: l10n.homeRouteHint,
    );
  }
}

/// Eyebrow with icon and chevron, a title, an optional big value and one
/// caption line — the metric-tile rhythm, made tappable.
class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.tint,
    required this.semanticLabel,
    required this.onTap,
    required this.title,
    required this.caption,
    this.value,
    this.captionColor,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final String semanticLabel;
  final VoidCallback onTap;
  final String title;
  final String? value;
  final String caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) => GlassPanel(
    radius: OsmonRadius.md,
    padding: const EdgeInsets.all(OsmonSpace.s12),
    semanticLabel: semanticLabel,
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: OsmonSize.iconSm, color: tint),
            const SizedBox(width: OsmonSpace.s6),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: OsmonType.eyebrow,
                maxLines: 1,
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
        const SizedBox(height: OsmonSpace.s8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Flexible(
              child: Text(
                title,
                style: OsmonType.titleSmall,
                maxLines: value == null ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null) ...<Widget>[
              const SizedBox(width: OsmonSpace.s6),
              Text(value!, style: OsmonType.numberMedium, maxLines: 1),
            ],
          ],
        ),
        const Spacer(),
        const SizedBox(height: OsmonSpace.s4),
        Text(
          caption,
          style: OsmonType.caption.copyWith(
            color: captionColor ?? OsmonColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
