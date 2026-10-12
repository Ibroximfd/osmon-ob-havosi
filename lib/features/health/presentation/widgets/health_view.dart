import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../ads/widgets/inline_banner_ad.dart';
import '../../../../core/bloc/load_status.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/severity_pill.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../weather/domain/services/pressure_trend.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../domain/air_quality.dart';
import '../../domain/health_assessment.dart';
import '../bloc/health_bloc.dart';
import 'health_labels.dart';

class HealthView extends StatelessWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          final bloc = context.read<HealthBloc>();
          return SkyScrollView(
            onRefresh: () async {
              bloc.add(const HealthRequested());
              await bloc.stream.firstWhere((s) => !s.status.isBusy);
            },
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l10n.healthTitle,
                  subtitle: state.place == null
                      ? null
                      : l10n.healthSubtitle(state.place!.name),
                ),
              ),
              SliverToBoxAdapter(
                child: switch (state.status) {
                  LoadStatus.initial ||
                  LoadStatus.loading => const _HealthSkeleton(),
                  LoadStatus.failure || LoadStatus.offline => ErrorStateView(
                    failure: state.failure,
                    onRetry: () => bloc.add(const HealthRequested()),
                  ),
                  LoadStatus.empty => MessageStateView(
                    icon: LucideIcons.mapPin,
                    title: l10n.homeEmptyTitle,
                    message: l10n.homeEmptyMessage,
                  ),
                  LoadStatus.ready => _HealthContent(state: state),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HealthContent extends StatelessWidget {
  const _HealthContent({required this.state});

  final HealthState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weather = context.watch<WeatherBloc>().state;
    final month = DateTime.now().month;
    final report = state.report!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: OsmonSpace.s16),
        _AqiCard(reading: report.current, category: state.aqiCategory),
        Eyebrow(l10n.healthPollenTitle),
        _PollenCard(state: state, month: month),
        Eyebrow(l10n.healthPressureTitle),
        _PressureCard(trend: weather.pressureTrend),
        const SizedBox(height: OsmonSpace.s8),
        _RiskTiles(
          trend: weather.pressureTrend,
          breathing: state.breathingRisk(month),
          apparentTemperature: weather.forecast?.current.apparentTemperature,
          uvIndex: weather.forecast?.today?.uvIndexMax,
        ),
        const InlineBannerAd(),
        Text(
          l10n.healthDisclaimer,
          style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
        ),
      ],
    );
  }
}

class _AqiCard extends StatelessWidget {
  const _AqiCard({required this.reading, required this.category});

  final AirReading reading;
  final AqiCategory? category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final aqi = reading.usAqi;
    final level = category;
    final pollutants = <(String, double?)>[
      ('PM2.5', reading.pm25),
      ('PM10', reading.pm10),
      ('NO2', reading.nitrogenDioxide),
      ('O3', reading.ozone),
      (l10n.healthDust, reading.dust),
    ];
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.healthAqiTitle.toUpperCase(), style: OsmonType.eyebrow),
          const SizedBox(height: OsmonSpace.s8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                aqi?.round().toString() ?? '—',
                style: OsmonType.numberLarge,
              ),
              const SizedBox(width: OsmonSpace.s12),
              if (level != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: OsmonSpace.s8),
                  child: SeverityPill(
                    severity: aqiSeverity(level),
                    label: aqiLabel(l10n, level),
                  ),
                ),
            ],
          ),
          if (level != null) ...<Widget>[
            const SizedBox(height: OsmonSpace.s6),
            Text(aqiAdvice(l10n, level), style: OsmonType.body),
          ],
          const SizedBox(height: OsmonSpace.s12),
          const Divider(height: 1, color: OsmonColors.divider),
          const SizedBox(height: OsmonSpace.s10),
          Wrap(
            spacing: OsmonSpace.s16,
            runSpacing: OsmonSpace.s6,
            children: <Widget>[
              for (final (name, value) in pollutants)
                if (value != null)
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: '$name ',
                          style: OsmonType.caption.copyWith(
                            color: OsmonColors.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: value.round().toString(),
                          style: OsmonType.captionStrong,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollenCard extends StatelessWidget {
  const _PollenCard({required this.state, required this.month});

  final HealthState state;
  final int month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final measured = state.measuredPollen;
    final seasonal = state.seasonalPollen(month);
    final rows = <(String, PollenLevel)>[
      for (final entry in measured)
        (pollenTypeLabel(l10n, entry.key), entry.value),
      if (measured.isEmpty)
        for (final s in seasonal) (allergenLabel(l10n, s.allergen), s.level),
    ];
    final source = measured.isNotEmpty
        ? l10n.healthPollenMeasured
        : seasonal.isNotEmpty
        ? l10n.healthPollenSeasonal
        : null;
    return GlassPanel(
      child: rows.isEmpty
          ? Text(
              l10n.healthPollenNoData,
              style: OsmonType.body.copyWith(color: OsmonColors.textSecondary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var i = 0; i < rows.length; i++) ...<Widget>[
                  if (i > 0)
                    const Divider(
                      height: OsmonSpace.s16,
                      color: OsmonColors.divider,
                    ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(rows[i].$1, style: OsmonType.body)),
                      Builder(
                        builder: (context) {
                          final (severity, label) = pollenLevelBadge(
                            l10n,
                            rows[i].$2,
                          );
                          return SeverityPill(severity: severity, label: label);
                        },
                      ),
                    ],
                  ),
                ],
                if (source != null) ...<Widget>[
                  const SizedBox(height: OsmonSpace.s12),
                  Text(
                    source,
                    style: OsmonType.micro.copyWith(
                      color: OsmonColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _PressureCard extends StatelessWidget {
  const _PressureCard({required this.trend});

  final PressureTrend? trend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = formatsOf(context);
    final history = context.select<WeatherBloc, List<double>>(
      (bloc) =>
          bloc.state.forecast?.pressureHistory
              .map((s) => s.pressure)
              .toList() ??
          const <double>[],
    );
    final value = trend;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (history.length > 1) _PressureChart(values: history),
          if (value != null) ...<Widget>[
            const SizedBox(height: OsmonSpace.s10),
            Text(
              '${formats.pressureValue(value.current)} ${formats.pressureUnitLabel} · '
              '${switch (value.direction) {
                PressureDirection.falling => l10n.pressureFalling(formats.pressureDelta(value.change24h)),
                PressureDirection.rising => l10n.pressureRising(formats.pressureDelta(value.change24h)),
                PressureDirection.steady => l10n.pressureSteady,
              }}',
              style: OsmonType.bodyStrong,
            ),
            const SizedBox(height: OsmonSpace.s4),
            Text(
              switch (value.sensitivity) {
                MeteoSensitivity.low => l10n.sensitivityLow,
                MeteoSensitivity.moderate => l10n.sensitivityModerate,
                MeteoSensitivity.high => l10n.sensitivityHigh,
              },
              style: OsmonType.body.copyWith(color: OsmonColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// 24 hours of sea-level pressure; the last bar (now) is highlighted.
class _PressureChart extends StatelessWidget {
  const _PressureChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final low = values.reduce((a, b) => a < b ? a : b);
    final high = values.reduce((a, b) => a > b ? a : b);
    final span = (high - low).abs() < 1 ? 1 : high - low;
    return SizedBox(
      height: OsmonSize.chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (var i = 0; i < values.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: OsmonSpace.s2),
            Expanded(
              child: FractionallySizedBox(
                heightFactor: 0.25 + 0.75 * (values[i] - low) / span,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i == values.length - 1
                        ? OsmonColors.accent
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
}

class _RiskTiles extends StatelessWidget {
  const _RiskTiles({
    required this.trend,
    required this.breathing,
    required this.apparentTemperature,
    required this.uvIndex,
  });

  final PressureTrend? trend;
  final BreathingRisk? breathing;
  final double? apparentTemperature;
  final double? uvIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String level(int index) => <String>[
      l10n.severityLow,
      l10n.severityModerate,
      l10n.severityHigh,
    ][index];
    Color tone(int index) => <Color>[
      OsmonColors.good,
      OsmonColors.moderate,
      OsmonColors.severe,
    ][index];
    final migraine = trend?.sensitivity.index;
    final breath = breathing?.index;
    final heat = apparentTemperature == null
        ? null
        : heatStressOf(apparentTemperature!).index;
    final uv = uvIndex;
    return TileGrid(
      children: <Widget>[
        MetricTile(
          icon: LucideIcons.brain,
          label: l10n.healthMigraine,
          value: migraine == null ? '—' : level(migraine),
          accent: migraine == null ? null : tone(migraine),
        ),
        MetricTile(
          icon: LucideIcons.wind,
          label: l10n.healthBreathing,
          value: breath == null ? '—' : level(breath),
          accent: breath == null ? null : tone(breath),
        ),
        MetricTile(
          icon: LucideIcons.thermometerSun,
          label: l10n.healthHeat,
          value: heat == null
              ? '—'
              : <String>[
                  l10n.heatNone,
                  l10n.heatCaution,
                  l10n.heatDanger,
                ][heat],
          accent: heat == null ? null : tone(heat),
        ),
        MetricTile(
          icon: LucideIcons.sun,
          label: l10n.healthUvSkin,
          value: uv == null ? '—' : uv.round().toString(),
          caption: uv == null
              ? null
              : uv >= 8
              ? l10n.uvCaptionVeryHigh
              : uv >= 6
              ? l10n.uvCaptionHigh
              : uv >= 3
              ? l10n.uvCaptionModerate
              : l10n.uvCaptionLow,
        ),
      ],
    );
  }
}

class _HealthSkeleton extends StatelessWidget {
  const _HealthSkeleton();

  @override
  Widget build(BuildContext context) => const ShimmerScope(
    child: Padding(
      padding: EdgeInsets.only(top: OsmonSpace.s16),
      child: Column(
        children: <Widget>[
          SkeletonBlock(
            height: OsmonSize.healthAqiCardHeight,
            radius: OsmonRadius.lg,
          ),
          SizedBox(height: OsmonSpace.s24),
          SkeletonBlock(
            height: OsmonSize.healthPollenCardHeight,
            radius: OsmonRadius.lg,
          ),
          SizedBox(height: OsmonSpace.s24),
          SkeletonBlock(
            height: OsmonSize.healthAqiCardHeight,
            radius: OsmonRadius.lg,
          ),
        ],
      ),
    ),
  );
}
