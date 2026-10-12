import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' hide MapEvent;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/switch_row.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../settings/presentation/widgets/notification_denied_listener.dart';
import '../../../weather/domain/entities/forecast.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../../weather/presentation/widgets/outlook_card.dart';
import '../bloc/map_bloc.dart';
import 'map_controls.dart';
import 'osmon_map.dart';

/// Precipitation for the next two hours: the moving field around the user,
/// the 15-minute bars for their own spot, and the alert switches.
class RadarView extends StatefulWidget {
  const RadarView({super.key});

  @override
  State<RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<RadarView> {
  final MapController _controller = MapController();

  static const double _radarZoom = 7;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weather = context.watch<WeatherBloc>().state;
    final tint = weather.scene.palette.tint;
    final forecast = weather.forecast;
    final placeName = weather.place?.name ?? '';
    return Scaffold(
      body: NotificationDeniedListener(
        child: SkyScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: ScreenHeader(
                title: l10n.radarTitle,
                subtitle: l10n.radarSubtitle(placeName),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: OsmonSpace.s16),
                child: _RadarPanel(
                  controller: _controller,
                  tint: tint,
                  zoom: _radarZoom,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: OsmonSpace.s8),
                child: Text(
                  l10n.radarModelNote,
                  style: OsmonType.micro.copyWith(
                    color: OsmonColors.textTertiary,
                  ),
                ),
              ),
            ),
            if (forecast != null) ...<Widget>[
              SliverToBoxAdapter(child: Eyebrow(l10n.radarNext2h)),
              SliverToBoxAdapter(
                child: _NowcastPanel(forecast: forecast, tint: tint),
              ),
            ],
            SliverToBoxAdapter(child: Eyebrow(l10n.radarAlerts)),
            const SliverToBoxAdapter(child: _AlertSwitches()),
          ],
        ),
      ),
    );
  }
}

class _RadarPanel extends StatelessWidget {
  const _RadarPanel({
    required this.controller,
    required this.tint,
    required this.zoom,
  });

  final MapController controller;
  final Color tint;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final formats = formatsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(OsmonRadius.lg),
      child: SizedBox(
        height: OsmonSize.radarPanelHeight,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: OsmonMap(
                controller: controller,
                tint: tint,
                initialZoom: zoom,
              ),
            ),
            Positioned(
              left: OsmonSpace.s8,
              right: OsmonSpace.s8,
              bottom: OsmonSpace.s28,
              child: BlocBuilder<MapBloc, MapState>(
                buildWhen: (previous, current) =>
                    previous.step != current.step ||
                    previous.isPlaying != current.isPlaying ||
                    previous.grid != current.grid,
                builder: (context, state) => PrecipitationTimeline(
                  stepTimes: state.grid?.stepTimes ?? const <DateTime>[],
                  step: state.step,
                  isPlaying: state.isPlaying,
                  formats: formats,
                  tint: tint,
                  onStep: (step) => context.read<MapBloc>().add(
                    MapTimelineStepSelected(step),
                  ),
                  onTogglePlay: () =>
                      context.read<MapBloc>().add(const MapPlaybackToggled()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowcastPanel extends StatelessWidget {
  const _NowcastPanel({required this.forecast, required this.tint});

  final Forecast forecast;
  final Color tint;

  static const int _steps = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = formatsOf(context);
    final steps = forecast.nowcast.take(_steps).toList();
    final peak = steps.isEmpty
        ? null
        : steps.reduce((a, b) => a.precipitation >= b.precipitation ? a : b);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NowcastBars(steps: steps, color: tint, height: OsmonSize.chartHeight),
          const SizedBox(height: OsmonSpace.s6),
          if (steps.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (final label in <String>[
                  l10n.relativeNow,
                  formats.time(steps[steps.length ~/ 2].time),
                  formats.time(steps.last.time),
                ])
                  Text(
                    label,
                    style: OsmonType.micro.copyWith(
                      color: OsmonColors.textTertiary,
                    ),
                  ),
              ],
            ),
          if (peak != null && peak.precipitation >= 0.05) ...<Widget>[
            const SizedBox(height: OsmonSpace.s10),
            Text(
              l10n.radarPeak(
                formats.time(peak.time),
                peak.rate.toStringAsFixed(1),
              ),
              style: OsmonType.caption,
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertSwitches extends StatelessWidget {
  const _AlertSwitches();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.select<SettingsBloc, AppSettings>(
      (bloc) => bloc.state.settings,
    );
    void toggle(NotificationKind kind, bool enabled) => context
        .read<SettingsBloc>()
        .add(SettingsNotificationToggled(kind, enabled: enabled));
    final rows = <(NotificationKind, String)>[
      (NotificationKind.rainSoon, l10n.radarAlertRain),
      (NotificationKind.severeWeather, l10n.radarAlertSevere),
      (NotificationKind.frost, l10n.radarAlertFrost),
      (NotificationKind.dust, l10n.radarAlertDust),
    ];
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s14,
        vertical: OsmonSpace.s4,
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, color: OsmonColors.divider),
            SwitchRow(
              title: rows[i].$2,
              value: settings.isEnabled(rows[i].$1),
              onChanged: (enabled) => toggle(rows[i].$1, enabled),
            ),
          ],
        ],
      ),
    );
  }
}
