import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/osmon_button.dart';
import '../../../../core/widgets/osmon_chip.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/weather_glyph.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../domain/route_models.dart';
import '../bloc/route_bloc.dart';

class RouteView extends StatelessWidget {
  const RouteView({super.key});

  Future<void> _pick(BuildContext context, {required bool origin}) async {
    final bloc = context.read<RouteBloc>();
    final place = await context.push<Place>(AppRoutes.pickPlace);
    if (place == null) return;
    bloc.add(origin ? RouteOriginChosen(place) : RouteDestinationChosen(place));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = context.select<WeatherBloc, Color>(
      (bloc) => bloc.state.scene.palette.tint,
    );
    return Scaffold(
      body: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          final bloc = context.read<RouteBloc>();
          final canSave = state.from != null && state.to != null;
          return SkyScrollView(
            clearNavBar: false,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l10n.routeTitle,
                  showBack: true,
                  trailing: canSave
                      ? OsmonIconButton(
                          icon: state.isSaved
                              ? LucideIcons.bookmarkMinus
                              : LucideIcons.bookmarkPlus,
                          tooltip: state.isSaved
                              ? l10n.routeUnsave
                              : l10n.routeSave,
                          highlighted: state.isSaved,
                          onPressed: () => bloc.add(const RouteSaveToggled()),
                        )
                      : null,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: OsmonSpace.s16),
                  child: _EndpointsCard(
                    from: state.from,
                    to: state.to,
                    tint: tint,
                    onPickFrom: () => _pick(context, origin: true),
                    onPickTo: () => _pick(context, origin: false),
                    onSwap: () => bloc.add(const RouteSwapped()),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: Eyebrow(l10n.routeDeparture)),
              SliverToBoxAdapter(
                child: _DepartureChips(
                  selected: state.departure,
                  tint: tint,
                  onSelected: (option) =>
                      bloc.add(RouteDepartureChosen(option)),
                ),
              ),
              if (state.saved.isNotEmpty) ...<Widget>[
                SliverToBoxAdapter(child: Eyebrow(l10n.routeSaved)),
                SliverToBoxAdapter(
                  child: Wrap(
                    spacing: OsmonSpace.s8,
                    runSpacing: OsmonSpace.s8,
                    children: <Widget>[
                      for (final route in state.saved)
                        OsmonChip(
                          label: '${route.from.name} → ${route.to.name}',
                          icon: LucideIcons.bookmark,
                          selected:
                              route.key ==
                              (state.from != null && state.to != null
                                  ? SavedRoute(state.from!, state.to!).key
                                  : ''),
                          tint: tint,
                          onTap: () => bloc.add(RouteSavedChosen(route)),
                        ),
                    ],
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: switch (state.status) {
                  LoadStatus.initial || LoadStatus.empty => MessageStateView(
                    icon: LucideIcons.milestone,
                    title: l10n.routeEmptyTitle,
                    message: l10n.routeEmptyMessage,
                  ),
                  LoadStatus.loading => const ShimmerScope(
                    child: Padding(
                      padding: EdgeInsets.only(top: OsmonSpace.s20),
                      child: SkeletonBlock(
                        height: OsmonSize.skeletonListHeight,
                        radius: OsmonRadius.lg,
                      ),
                    ),
                  ),
                  LoadStatus.failure || LoadStatus.offline => ErrorStateView(
                    failure: state.failure,
                    onRetry: () => bloc.add(const RouteRetried()),
                  ),
                  LoadStatus.ready => _PlanView(plan: state.plan!, tint: tint),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EndpointsCard extends StatelessWidget {
  const _EndpointsCard({
    required this.from,
    required this.to,
    required this.tint,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
  });

  final Place? from;
  final Place? to;
  final Color tint;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassPanel(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                _EndpointRow(
                  label: l10n.routeFrom,
                  value: from?.name,
                  hint: l10n.routeChoose,
                  dotFilled: false,
                  tint: tint,
                  onTap: onPickFrom,
                ),
                const Divider(
                  height: OsmonSpace.s16,
                  color: OsmonColors.divider,
                ),
                _EndpointRow(
                  label: l10n.routeTo,
                  value: to?.name,
                  hint: l10n.routeChoose,
                  dotFilled: true,
                  tint: tint,
                  onTap: onPickTo,
                ),
              ],
            ),
          ),
          const SizedBox(width: OsmonSpace.s8),
          OsmonIconButton(
            icon: LucideIcons.arrowUpDown,
            tooltip: l10n.routeSwap,
            onPressed: onSwap,
          ),
        ],
      ),
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({
    required this.label,
    required this.value,
    required this.hint,
    required this.dotFilled,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String hint;
  final bool dotFilled;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(OsmonRadius.sm),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: OsmonSize.tapTarget),
      child: Row(
        children: <Widget>[
          Container(
            width: OsmonSpace.s12,
            height: OsmonSpace.s12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotFilled ? tint : null,
              border: Border.all(color: tint, width: 2.5),
            ),
          ),
          const SizedBox(width: OsmonSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(label.toUpperCase(), style: OsmonType.eyebrow),
                Text(
                  value ?? hint,
                  style: OsmonType.bodyStrong.copyWith(
                    color: value == null ? OsmonColors.textTertiary : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DepartureChips extends StatelessWidget {
  const _DepartureChips({
    required this.selected,
    required this.tint,
    required this.onSelected,
  });

  final DepartureOption selected;
  final Color tint;
  final ValueChanged<DepartureOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = <DepartureOption, String>{
      DepartureOption.now: l10n.departNow,
      DepartureOption.inOneHour: l10n.departIn1h,
      DepartureOption.inTwoHours: l10n.departIn2h,
      DepartureOption.inFourHours: l10n.departIn4h,
      DepartureOption.tomorrowMorning: l10n.departTomorrow,
    };
    return Wrap(
      spacing: OsmonSpace.s8,
      runSpacing: OsmonSpace.s8,
      children: <Widget>[
        for (final option in DepartureOption.values)
          OsmonChip(
            label: labels[option]!,
            selected: option == selected,
            tint: tint,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

String hazardLabel(AppLocalizations l10n, RouteHazard hazard) =>
    switch (hazard) {
      RouteHazard.storm => l10n.hazardStorm,
      RouteHazard.ice => l10n.hazardIce,
      RouteHazard.snow => l10n.hazardSnow,
      RouteHazard.fog => l10n.hazardFog,
      RouteHazard.heavyRain => l10n.hazardHeavyRain,
      RouteHazard.strongWind => l10n.hazardWind,
    };

class _PlanView extends StatelessWidget {
  const _PlanView({required this.plan, required this.tint});

  final RoutePlan plan;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = formatsOf(context);
    final delay = plan.betterDelay;
    final (verdictIcon, verdictColor, verdict) = !plan.hasHazards
        ? (LucideIcons.shieldCheck, OsmonColors.good, l10n.routeClear)
        : delay != null
        ? (
            LucideIcons.clock,
            OsmonColors.moderate,
            l10n.routeDelayAdvice(formats.duration(delay)),
          )
        : (
            LucideIcons.alertTriangle,
            OsmonColors.severe,
            l10n.routeHazardsAhead,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: OsmonSpace.s20),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.routeSummary(
                  plan.path.distanceKm.round().toString(),
                  formats.duration(plan.path.duration),
                ),
                style: OsmonType.titleSmall,
              ),
              if (plan.path.isEstimated) ...<Widget>[
                const SizedBox(height: OsmonSpace.s4),
                Text(
                  l10n.routeEstimated,
                  style: OsmonType.micro.copyWith(
                    color: OsmonColors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: OsmonSpace.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    verdictIcon,
                    size: OsmonSize.iconMd,
                    color: verdictColor,
                  ),
                  const SizedBox(width: OsmonSpace.s10),
                  Expanded(child: Text(verdict, style: OsmonType.body)),
                ],
              ),
            ],
          ),
        ),
        Eyebrow(l10n.routeAlong),
        GlassPanel(
          padding: const EdgeInsets.symmetric(
            horizontal: OsmonSpace.s14,
            vertical: OsmonSpace.s6,
          ),
          child: Column(
            children: <Widget>[
              for (var i = 0; i < plan.checkpoints.length; i++) ...<Widget>[
                if (i > 0) const Divider(height: 1, color: OsmonColors.divider),
                _CheckpointRow(
                  checkpoint: plan.checkpoints[i],
                  name: i == 0
                      ? plan.from.name
                      : i == plan.checkpoints.length - 1
                      ? plan.to.name
                      : plan.checkpoints[i].name ??
                            l10n.routeKm(
                              plan.checkpoints[i].distanceKm.round().toString(),
                            ),
                  formats: formats,
                  tint: tint,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: OsmonSpace.s8),
          child: Text(
            '© OSRM · © OpenStreetMap · ${l10n.dataAttribution}',
            style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _CheckpointRow extends StatelessWidget {
  const _CheckpointRow({
    required this.checkpoint,
    required this.name,
    required this.formats,
    required this.tint,
  });

  final RouteCheckpoint checkpoint;
  final String name;
  final Formats formats;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weather = checkpoint.weather;
    final hazards = checkpoint.hazards;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: OsmonSpace.s48,
            child: Text(
              formats.time(checkpoint.eta),
              style: OsmonType.captionStrong.copyWith(
                color: OsmonColors.textSecondary,
              ),
            ),
          ),
          if (weather != null)
            WeatherGlyph(
              kind: GlyphKind.of(weather.condition, isDay: weather.isDay),
              size: OsmonSize.glyphSm,
            ),
          const SizedBox(width: OsmonSpace.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: OsmonType.bodyStrong.copyWith(
                    color: hazards.isEmpty ? null : OsmonColors.moderate,
                  ),
                ),
                if (weather != null)
                  Text(
                    '${formats.temperature(weather.temperature)} · '
                    '${formats.condition(weather.condition)}',
                    style: OsmonType.caption.copyWith(
                      color: OsmonColors.textSecondary,
                    ),
                  ),
                if (hazards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: OsmonSpace.s4),
                    child: Text(
                      hazards.map((h) => hazardLabel(l10n, h)).join(' · '),
                      style: OsmonType.captionStrong.copyWith(
                        color: OsmonColors.elevated,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
