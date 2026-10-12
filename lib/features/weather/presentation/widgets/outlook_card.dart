import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/services/nowcast_outlook.dart';

/// The next-two-hours answer: rain starting, rain stopping, dust, or dry.
class OutlookCard extends StatelessWidget {
  const OutlookCard({
    super.key,
    required this.outlook,
    required this.nowcast,
    required this.air,
    required this.formats,
    required this.tint,
    required this.onTap,
  });

  final NowcastOutlook outlook;
  final List<NowcastStep> nowcast;
  final AirSnapshot? air;
  final Formats formats;
  final Color tint;
  final VoidCallback onTap;

  static const double _dustAlert = 150;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDusty = (air?.dust ?? 0) >= _dustAlert || (air?.pm10 ?? 0) >= 250;
    final (icon, title, subtitle, accent) = switch (outlook) {
      PrecipitationAhead(
        :final startsIn,
        :final lasts,
        :final intensity,
        :final isSnow,
      ) =>
        (
          isSnow ? LucideIcons.snowflake : LucideIcons.umbrella,
          isSnow
              ? l10n.outlookSnowAhead(startsIn.inMinutes)
              : l10n.outlookRainAhead(startsIn.inMinutes),
          lasts == null
              ? l10n.outlookLastsLong(_intensity(l10n, intensity))
              : l10n.outlookLasts(
                  formats.duration(lasts),
                  _intensity(l10n, intensity),
                ),
          tint,
        ),
      PrecipitationNow(:final endsIn, :final intensity, :final isSnow) => (
        isSnow ? LucideIcons.snowflake : LucideIcons.cloudRain,
        isSnow ? l10n.outlookSnowNow : l10n.outlookRainNow,
        endsIn == null
            ? l10n.outlookLastsLong(_intensity(l10n, intensity))
            : l10n.outlookEndsIn(
                formats.duration(endsIn),
                _intensity(l10n, intensity),
              ),
        tint,
      ),
      DryOutlook() when isDusty => (
        LucideIcons.wind,
        l10n.notifDustTitle,
        l10n.outlookDustBody((air?.usAqi ?? 0).round().toString()),
        OsmonColors.elevated,
      ),
      DryOutlook() => (
        LucideIcons.shieldCheck,
        l10n.outlookDry,
        l10n.outlookDrySubtitle,
        OsmonColors.good,
      ),
    };
    final showsBars = outlook is! DryOutlook;
    return GlassPanel(
      onTap: onTap,
      fill: accent == OsmonColors.elevated
          ? OsmonColors.elevatedSoft
          : OsmonColors.glassFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(OsmonRadius.sm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(OsmonSpace.s8),
                  child: Icon(icon, size: OsmonSize.iconMd, color: accent),
                ),
              ),
              const SizedBox(width: OsmonSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: OsmonType.bodyStrong),
                    Text(
                      subtitle,
                      style: OsmonType.caption.copyWith(
                        color: OsmonColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: OsmonSize.iconSm,
                color: OsmonColors.textTertiary,
              ),
            ],
          ),
          if (showsBars && nowcast.isNotEmpty) ...<Widget>[
            const SizedBox(height: OsmonSpace.s12),
            NowcastBars(steps: nowcast, color: tint),
          ],
        ],
      ),
    );
  }

  static String _intensity(AppLocalizations l10n, PrecipitationIntensity i) =>
      switch (i) {
        PrecipitationIntensity.light => l10n.intensityLight,
        PrecipitationIntensity.moderate => l10n.intensityModerate,
        PrecipitationIntensity.heavy => l10n.intensityHeavy,
      };
}

/// Fifteen-minute precipitation bars, scaled to a heavy-rain ceiling so a
/// drizzle looks small and a downpour fills the strip.
class NowcastBars extends StatelessWidget {
  const NowcastBars({
    super.key,
    required this.steps,
    required this.color,
    this.height = OsmonSize.sparkHeight,
  });

  final List<NowcastStep> steps;
  final Color color;
  final double height;

  /// mm per 15 min that fills the bar (≈ 8 mm/h, heavy rain).
  static const double _ceiling = 2;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (var i = 0; i < steps.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: OsmonSpace.s4),
          Expanded(
            child: FractionallySizedBox(
              heightFactor: (0.08 + steps[i].precipitation / _ceiling).clamp(
                0.08,
                1,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: steps[i].precipitation >= wetStepThreshold
                      ? color
                      : OsmonColors.glassFillStrong,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(OsmonRadius.xs),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
