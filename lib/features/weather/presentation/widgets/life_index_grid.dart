import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../core/widgets/severity_pill.dart';
import '../../domain/services/life_indices.dart';

class LifeIndexGrid extends StatelessWidget {
  const LifeIndexGrid({super.key, required this.indices});

  final List<LifeIndex> indices;

  @override
  Widget build(BuildContext context) => TileGrid(
    children: <Widget>[for (final index in indices) _IndexTile(index: index)],
  );
}

class _IndexTile extends StatelessWidget {
  const _IndexTile({required this.index});

  final LifeIndex index;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, name) = switch (index.activity) {
      LifeActivity.laundry => (LucideIcons.shirt, l10n.indexLaundry),
      LifeActivity.carWash => (LucideIcons.car, l10n.indexCarWash),
      LifeActivity.running => (LucideIcons.footprints, l10n.indexRunning),
      LifeActivity.cycling => (LucideIcons.bike, l10n.indexCycling),
      LifeActivity.walking => (LucideIcons.trees, l10n.indexWalking),
      LifeActivity.stargazing => (LucideIcons.moonStar, l10n.indexStargazing),
    };
    final (severity, rating) = switch (index.rating) {
      IndexRating.good => (Severity.good, l10n.ratingGood),
      IndexRating.fair => (Severity.moderate, l10n.ratingFair),
      IndexRating.poor => (Severity.severe, l10n.ratingPoor),
    };
    return GlassPanel(
      radius: OsmonRadius.md,
      padding: const EdgeInsets.all(OsmonSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                size: OsmonSize.iconMd,
                color: OsmonColors.textSecondary,
              ),
              const Spacer(),
              SeverityPill(severity: severity, label: rating),
            ],
          ),
          const SizedBox(height: OsmonSpace.s10),
          Text(
            name,
            style: OsmonType.bodyStrong,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: OsmonSpace.s2),
          Text(
            _reason(l10n, index.reason),
            style: OsmonType.caption.copyWith(color: OsmonColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static String _reason(AppLocalizations l10n, IndexReason reason) =>
      switch (reason) {
        IndexReason.rainExpected => l10n.reasonRainExpected,
        IndexReason.tooHumid => l10n.reasonTooHumid,
        IndexReason.tooCold => l10n.reasonTooCold,
        IndexReason.tooHot => l10n.reasonTooHot,
        IndexReason.goodDrying => l10n.reasonGoodDrying,
        IndexReason.dryDaysAhead => l10n.reasonDryDaysAhead,
        IndexReason.dusty => l10n.reasonDusty,
        IndexReason.freezing => l10n.reasonFreezing,
        IndexReason.badAir => l10n.reasonBadAir,
        IndexReason.stormy => l10n.reasonStormy,
        IndexReason.windy => l10n.reasonWindy,
        IndexReason.wet => l10n.reasonWet,
        IndexReason.pleasant => l10n.reasonPleasant,
        IndexReason.clearSky => l10n.reasonClearSky,
        IndexReason.someClouds => l10n.reasonSomeClouds,
        IndexReason.cloudy => l10n.reasonCloudy,
      };
}
