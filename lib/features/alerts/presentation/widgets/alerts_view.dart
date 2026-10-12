import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../ads/widgets/inline_banner_ad.dart';
import '../../../../core/bloc/load_status.dart';
import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/severity_pill.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../domain/weather_alert.dart';
import '../bloc/alerts_bloc.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: BlocBuilder<AlertsBloc, AlertsState>(
        builder: (context, state) {
          final bloc = context.read<AlertsBloc>();
          final formats = formatsOf(context);
          final today = DateTime.now();
          final todayDate = DateTime.utc(today.year, today.month, today.day);
          return SkyScrollView(
            clearNavBar: false,
            onRefresh: () async {
              bloc.add(const AlertsRequested());
              await bloc.stream.firstWhere((s) => !s.status.isBusy);
            },
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l10n.alertsTitle,
                  subtitle: l10n.alertsSubtitle,
                  showBack: true,
                ),
              ),
              ...switch (state.status) {
                LoadStatus.initial || LoadStatus.loading => <Widget>[
                  const SliverToBoxAdapter(child: _AlertsSkeleton()),
                ],
                LoadStatus.failure || LoadStatus.offline => <Widget>[
                  SliverToBoxAdapter(
                    child: ErrorStateView(
                      failure: state.failure,
                      onRetry: () => bloc.add(const AlertsRequested()),
                    ),
                  ),
                ],
                LoadStatus.empty => <Widget>[
                  SliverToBoxAdapter(
                    child: MessageStateView(
                      icon: LucideIcons.shieldCheck,
                      iconColor: OsmonColors.good,
                      title: l10n.alertsEmptyTitle,
                      message: l10n.alertsEmptyMessage,
                    ),
                  ),
                ],
                LoadStatus.ready => <Widget>[
                  if (state.ownAlerts.isNotEmpty) ...<Widget>[
                    SliverToBoxAdapter(child: Eyebrow(l10n.alertsYourPlace)),
                    SliverList.separated(
                      itemCount: state.ownAlerts.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: OsmonSpace.s8),
                      itemBuilder: (context, i) => _AlertCard(
                        alert: state.ownAlerts[i],
                        formats: formats,
                        today: todayDate,
                      ),
                    ),
                  ],
                  if (state.regionAlerts.isNotEmpty)
                    SliverToBoxAdapter(child: Eyebrow(l10n.alertsRegions)),
                  SliverList.separated(
                    itemCount: state.regionAlerts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: OsmonSpace.s8),
                    itemBuilder: (context, i) => _AlertCard(
                      key: ValueKey<String>(
                        '${state.regionAlerts[i].place.key}-${state.regionAlerts[i].kind.name}-${state.regionAlerts[i].day}',
                      ),
                      alert: state.regionAlerts[i],
                      formats: formats,
                      today: todayDate,
                    ),
                  ),
                  const SliverToBoxAdapter(child: InlineBannerAd()),
                ],
              },
            ],
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    super.key,
    required this.alert,
    required this.formats,
    required this.today,
  });

  final WeatherAlert alert;
  final Formats formats;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (severity, level, fill) = switch (alert.level) {
      AlertLevel.yellow => (
        Severity.moderate,
        l10n.alertYellow,
        OsmonColors.moderateSoft,
      ),
      AlertLevel.orange => (
        Severity.elevated,
        l10n.alertOrange,
        OsmonColors.elevatedSoft,
      ),
      AlertLevel.red => (
        Severity.severe,
        l10n.alertRed,
        OsmonColors.severeSoft,
      ),
    };
    final (icon, title, advice) = switch (alert.kind) {
      AlertKind.heavyRain => (
        LucideIcons.cloudRain,
        l10n.alertKindHeavyRain,
        l10n.alertAdviceHeavyRain,
      ),
      AlertKind.thunderstorm => (
        LucideIcons.zap,
        l10n.alertKindThunderstorm,
        l10n.alertAdviceThunderstorm,
      ),
      AlertKind.hail => (
        LucideIcons.cloudHail,
        l10n.alertKindHail,
        l10n.alertAdviceHail,
      ),
      AlertKind.heat => (
        LucideIcons.thermometerSun,
        l10n.alertKindHeat,
        l10n.alertAdviceHeat,
      ),
      AlertKind.frost => (
        LucideIcons.thermometerSnowflake,
        l10n.alertKindFrost,
        l10n.alertAdviceFrost,
      ),
      AlertKind.wind => (
        LucideIcons.wind,
        l10n.alertKindWind,
        l10n.alertAdviceWind,
      ),
      AlertKind.snow => (
        LucideIcons.snowflake,
        l10n.alertKindSnow,
        l10n.alertAdviceSnow,
      ),
      AlertKind.dust => (
        LucideIcons.haze,
        l10n.alertKindDust,
        l10n.alertAdviceDust,
      ),
    };
    final value = switch (alert.kind) {
      AlertKind.heavyRain ||
      AlertKind.thunderstorm ||
      AlertKind.hail => '${alert.value.toStringAsFixed(0)} ${l10n.unitMm}',
      AlertKind.heat || AlertKind.frost => formats.temperature(alert.value),
      AlertKind.wind => formats.wind(alert.value),
      AlertKind.snow => '${alert.value.toStringAsFixed(0)} ${l10n.unitCm}',
      AlertKind.dust => '${alert.value.round()} ${l10n.unitMicrograms}',
    };
    return GlassPanel(
      fill: fill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SeverityPill(severity: severity, label: level.toUpperCase()),
              const Spacer(),
              Text(
                '${formats.dayLabel(alert.day, today)} · ${formats.dayMonth(alert.day)}',
                style: OsmonType.micro.copyWith(
                  color: OsmonColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: OsmonSpace.s10),
          Row(
            children: <Widget>[
              Icon(icon, size: OsmonSize.iconLg, color: severity.color),
              const SizedBox(width: OsmonSpace.s10),
              Expanded(child: Text(title, style: OsmonType.titleSmall)),
              Text(value, style: OsmonType.bodyStrong),
            ],
          ),
          const SizedBox(height: OsmonSpace.s6),
          Row(
            children: <Widget>[
              const Icon(
                LucideIcons.mapPin,
                size: OsmonSize.iconSm,
                color: OsmonColors.textTertiary,
              ),
              const SizedBox(width: OsmonSpace.s4),
              Text(alert.place.name, style: OsmonType.captionStrong),
            ],
          ),
          const SizedBox(height: OsmonSpace.s6),
          Text(
            advice,
            style: OsmonType.caption.copyWith(color: OsmonColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AlertsSkeleton extends StatelessWidget {
  const _AlertsSkeleton();

  @override
  Widget build(BuildContext context) => ShimmerScope(
    child: Padding(
      padding: const EdgeInsets.only(top: OsmonSpace.s16),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < 4; i++) ...<Widget>[
            const SkeletonBlock(
              height: OsmonSize.healthAqiCardHeight - OsmonSpace.s20,
              radius: OsmonRadius.lg,
            ),
            const SizedBox(height: OsmonSpace.s8),
          ],
        ],
      ),
    ),
  );
}
