import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place_time.dart';
import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../core/widgets/osmon_chip.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/severity_pill.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../domain/field_advisor.dart';
import '../../domain/field_conditions.dart';
import '../bloc/field_bloc.dart';

String cropName(AppLocalizations l10n, Crop crop) => switch (crop) {
  Crop.wheat => l10n.cropWheat,
  Crop.cotton => l10n.cropCotton,
  Crop.grape => l10n.cropGrape,
  Crop.vegetables => l10n.cropVegetables,
  Crop.orchard => l10n.cropOrchard,
};

class FieldView extends StatelessWidget {
  const FieldView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = context.select<WeatherBloc, Color>(
      (bloc) => bloc.state.scene.palette.tint,
    );
    return Scaffold(
      body: BlocBuilder<FieldBloc, FieldState>(
        builder: (context, state) {
          final bloc = context.read<FieldBloc>();
          return SkyScrollView(
            clearNavBar: false,
            onRefresh: () async {
              bloc.add(const FieldRequested());
              await bloc.stream.firstWhere((s) => !s.status.isBusy);
            },
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l10n.fieldTitle,
                  subtitle: state.place == null
                      ? null
                      : '${state.place!.name} · ${cropName(l10n, state.crop)}',
                  showBack: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: OsmonSpace.s16),
                  child: Wrap(
                    spacing: OsmonSpace.s8,
                    runSpacing: OsmonSpace.s8,
                    children: <Widget>[
                      for (final crop in Crop.values)
                        OsmonChip(
                          label: cropName(l10n, crop),
                          selected: crop == state.crop,
                          tint: tint,
                          onTap: () => bloc.add(FieldCropSelected(crop)),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: switch (state.status) {
                  LoadStatus.initial ||
                  LoadStatus.loading => const ShimmerScope(
                    child: Padding(
                      padding: EdgeInsets.only(top: OsmonSpace.s16),
                      child: SkeletonBlock(
                        height: OsmonSize.skeletonListHeight,
                        radius: OsmonRadius.lg,
                      ),
                    ),
                  ),
                  LoadStatus.failure || LoadStatus.offline => ErrorStateView(
                    failure: state.failure,
                    onRetry: () => bloc.add(const FieldRequested()),
                  ),
                  LoadStatus.empty => MessageStateView(
                    icon: LucideIcons.mapPin,
                    title: l10n.homeEmptyTitle,
                    message: l10n.homeEmptyMessage,
                  ),
                  LoadStatus.ready => _FieldContent(state: state, tint: tint),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldContent extends StatelessWidget {
  const _FieldContent({required this.state, required this.tint});

  final FieldState state;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = formatsOf(context);
    final conditions = state.conditions!;
    final profile = CropProfile.of(state.crop);
    final frost = state.frost;
    final irrigation = state.irrigation;
    final gdd = state.growingDegreeDaysTotal;
    final today = conditions.days.isEmpty ? null : conditions.days.first;
    final isDry = conditions.soilMoisture < profile.dryMoisture;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: OsmonSpace.s16),
        if (frost != null) _FrostCard(frost: frost, formats: formats),
        const SizedBox(height: OsmonSpace.s8),
        TileGrid(
          children: <Widget>[
            MetricTile(
              icon: LucideIcons.thermometer,
              label: l10n.fieldSoilTemp,
              value: formats.temperature(conditions.soilTemperatureRoot),
              caption: l10n.fieldSoilTempCaption(
                formats.temperature(conditions.soilTemperatureSurface),
              ),
            ),
            MetricTile(
              icon: LucideIcons.droplet,
              label: l10n.fieldSoilMoisture,
              value: conditions.soilMoisture.toStringAsFixed(2),
              caption: 'm³/m³ · ${isDry ? l10n.moistureDry : l10n.moistureOk}',
              accent: isDry ? OsmonColors.elevated : null,
            ),
            MetricTile(
              icon: LucideIcons.sun,
              label: l10n.fieldEt0,
              value: today?.evapotranspiration.toStringAsFixed(1) ?? '—',
              caption: l10n.fieldEt0Caption,
            ),
            MetricTile(
              icon: LucideIcons.sprout,
              label: l10n.fieldGdd,
              value: gdd?.round().toString() ?? '—',
              caption: gdd == null
                  ? l10n.fieldGddNone
                  : l10n.fieldGddCaption(formats.temperature(profile.gddBase)),
            ),
          ],
        ),
        Eyebrow(l10n.fieldAdvice),
        if (irrigation != null) _IrrigationCard(advice: irrigation),
        const SizedBox(height: OsmonSpace.s8),
        _SprayCard(
          windows: state.sprayWindows,
          formats: formats,
          today: conditions.now,
          tint: tint,
        ),
        const SizedBox(height: OsmonSpace.s8),
        _HarvestCard(
          wetDay: state.wetDay,
          formats: formats,
          today: conditions.now,
        ),
        const SizedBox(height: OsmonSpace.s16),
        Text(
          l10n.fieldDisclaimer,
          style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
        ),
      ],
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.frost, required this.formats});

  final FrostOutlook frost;
  final Formats formats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (severity, label) = switch (frost.risk) {
      FrostRisk.none => (Severity.good, l10n.frostNone),
      FrostRisk.possible => (Severity.moderate, l10n.frostPossible),
      FrostRisk.likely => (Severity.severe, l10n.frostLikely),
    };
    return GlassPanel(
      fill: frost.risk == FrostRisk.likely
          ? OsmonColors.severeSoft
          : OsmonColors.glassFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.fieldFrostTitle.toUpperCase(),
                  style: OsmonType.eyebrow,
                ),
              ),
              SeverityPill(severity: severity, label: label),
            ],
          ),
          const SizedBox(height: OsmonSpace.s8),
          Text(
            formats.temperature(frost.coldest),
            style: OsmonType.numberLarge,
          ),
          Text(
            l10n.fieldFrostDetail(
              formats.dayMonth(frost.night),
              formats.temperature(frost.coldest),
            ),
            style: OsmonType.caption.copyWith(color: OsmonColors.textSecondary),
          ),
          if (frost.risk != FrostRisk.none) ...<Widget>[
            const SizedBox(height: OsmonSpace.s8),
            Text(l10n.fieldFrostAdvice, style: OsmonType.body),
          ],
        ],
      ),
    );
  }
}

class _AdviceRow extends StatelessWidget {
  const _AdviceRow({
    required this.icon,
    required this.color,
    required this.title,
    this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) => GlassPanel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: OsmonSize.iconMd, color: color),
        const SizedBox(width: OsmonSpace.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: OsmonType.bodyStrong),
              if (detail != null) ...<Widget>[
                const SizedBox(height: OsmonSpace.s2),
                Text(
                  detail!,
                  style: OsmonType.caption.copyWith(
                    color: OsmonColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _IrrigationCard extends StatelessWidget {
  const _IrrigationCard({required this.advice});

  final IrrigationAdvice advice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, color) = switch (advice.need) {
      IrrigationNeed.now => (l10n.irrigationNow, OsmonColors.elevated),
      IrrigationNeed.soon => (l10n.irrigationSoon, OsmonColors.moderate),
      IrrigationNeed.notNeeded => (l10n.irrigationNotNeeded, OsmonColors.good),
    };
    return _AdviceRow(
      icon: LucideIcons.droplets,
      color: color,
      title: title,
      detail: l10n.irrigationDetail(
        advice.deficitMillimetres.round().toString(),
        advice.cubicMetresPerHectare.round().toString(),
        advice.rainExpectedMillimetres.toStringAsFixed(1),
      ),
    );
  }
}

class _SprayCard extends StatelessWidget {
  const _SprayCard({
    required this.windows,
    required this.formats,
    required this.today,
    required this.tint,
  });

  final List<SprayWindow> windows;
  final Formats formats;
  final DateTime today;
  final Color tint;

  static const int _shown = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = windows.isEmpty
        ? l10n.sprayNone
        : <String>[
            for (final w in windows.take(_shown))
              l10n.sprayWindow(
                formats.dayLabel(w.start.dateOnly, today.dateOnly),
                formats.time(w.start),
                formats.time(w.end),
              ),
            l10n.sprayHint,
          ].join('\n');
    return _AdviceRow(
      icon: LucideIcons.sprayCan,
      color: windows.isEmpty ? OsmonColors.moderate : tint,
      title: l10n.sprayTitle,
      detail: detail,
    );
  }
}

class _HarvestCard extends StatelessWidget {
  const _HarvestCard({
    required this.wetDay,
    required this.formats,
    required this.today,
  });

  final FieldDay? wetDay;
  final Formats formats;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final day = wetDay;
    return _AdviceRow(
      icon: LucideIcons.wheat,
      color: day == null ? OsmonColors.good : OsmonColors.moderate,
      title: day == null
          ? l10n.harvestClear
          : l10n.harvestWarning(
              formats.dayLabel(day.date, today.dateOnly),
              formats.percent(day.precipitationProbability),
            ),
    );
  }
}
