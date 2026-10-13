import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' hide MapEvent;
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../ads/widgets/top_banner_ad.dart';
import '../../../../core/bloc/load_status.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../domain/weather_grid.dart';
import '../bloc/map_bloc.dart';
import 'map_controls.dart';
import 'osmon_map.dart';

/// Full-screen weather map: layer chips on top, zoom on the right, legend
/// and (for precipitation) the timeline just above the tab bar.
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) => _controller.move(
    _controller.camera.center,
    _controller.camera.zoom + delta,
  );

  void _recenter(MapState state) {
    final focus = state.focus;
    if (focus == null) return;
    _controller.move(
      LatLng(focus.point.latitude, focus.point.longitude),
      _controller.camera.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tint = context.select<WeatherBloc, Color>(
      (bloc) => bloc.state.scene.palette.tint,
    );
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: OsmonColors.ink,
      // The banner has its own strip above the map, so it never covers the
      // map or sits where a pan or a tap on the controls would land on it.
      body: Column(
        children: <Widget>[
          const TopBannerAd(),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Stack(
                children: <Widget>[
                  // Panels above repaint on their own (timeline, chips) without
                  // forcing the map to repaint with them, and vice versa.
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: OsmonMap(controller: _controller, tint: tint),
                    ),
                  ),
                  Positioned(
                    top: OsmonSpace.s12,
                    left: 0,
                    right: 0,
                    child: _TopBar(tint: tint),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: OsmonSpace.gutter,
                        ),
                        child: MapZoomControls(
                          onZoomIn: () => _zoomBy(1),
                          onZoomOut: () => _zoomBy(-1),
                          onRecenter: () =>
                              _recenter(context.read<MapBloc>().state),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: OsmonSpace.gutter,
                    right: OsmonSpace.gutter,
                    bottom: OsmonSize.navBarClearance + padding.bottom,
                    child: _BottomPanel(tint: tint),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
          previous.layer != current.layer ||
          previous.status != current.status ||
          previous.focus != current.focus,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OsmonSpace.gutter),
            // An opaque sheet, not blur: a backdrop filter over a moving map
            // is recomputed on every frame of a pan.
            child: GlassPanel(
              fill: OsmonColors.inkSheet,
              radius: OsmonRadius.md,
              padding: const EdgeInsets.symmetric(
                horizontal: OsmonSpace.s14,
                vertical: OsmonSpace.s10,
              ),
              child: Row(
                children: <Widget>[
                  Icon(LucideIcons.map, size: OsmonSize.iconMd, color: tint),
                  const SizedBox(width: OsmonSpace.s10),
                  Expanded(
                    child: Text(
                      l10n.mapTitle,
                      style: OsmonType.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (state.focus != null)
                    Flexible(
                      child: Text(
                        state.focus!.name,
                        style: OsmonType.caption.copyWith(
                          color: OsmonColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: OsmonSpace.s10),
          LayerChips(
            selected: state.layer,
            tint: tint,
            onSelected: (layer) =>
                context.read<MapBloc>().add(MapLayerSelected(layer)),
          ),
          if (state.status == LoadStatus.loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OsmonSpace.gutter,
                OsmonSpace.s8,
                OsmonSpace.gutter,
                0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(OsmonRadius.pill),
                child: LinearProgressIndicator(
                  minHeight: OsmonSize.progressBar,
                  color: tint,
                  backgroundColor: OsmonColors.glassFill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = formatsOf(context);
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final bloc = context.read<MapBloc>();
        final failed =
            state.status == LoadStatus.failure ||
            state.status == LoadStatus.offline;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (state.tileTemplate == null && state.tileFailure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: OsmonSpace.s8),
                child: Text(
                  l10n.mapTilesUnavailable,
                  textAlign: TextAlign.center,
                  style: OsmonType.micro.copyWith(
                    color: OsmonColors.textSecondary,
                  ),
                ),
              ),
            if (failed)
              Padding(
                padding: const EdgeInsets.only(bottom: OsmonSpace.s8),
                child: OfflineStyleNotice(
                  icon: LucideIcons.cloudOff,
                  title: l10n.mapGridFailed,
                  message: state.status == LoadStatus.offline
                      ? l10n.stateOfflineMessage
                      : l10n.stateErrorMessage,
                  actionLabel: l10n.actionRetry,
                  onAction: () {
                    final bounds = state.lastBounds;
                    if (bounds != null) bloc.add(MapViewportChanged(bounds));
                  },
                ),
              ),
            if (state.layer == MapLayer.precipitation) ...<Widget>[
              PrecipitationTimeline(
                stepTimes: state.grid?.stepTimes ?? const <DateTime>[],
                step: state.step,
                isPlaying: state.isPlaying,
                formats: formats,
                tint: tint,
                onStep: (step) => bloc.add(MapTimelineStepSelected(step)),
                onTogglePlay: () => bloc.add(const MapPlaybackToggled()),
              ),
              const SizedBox(height: OsmonSpace.s8),
            ],
            MapLegend(layer: state.layer, formats: formats),
          ],
        );
      },
    );
  }
}
