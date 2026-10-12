import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../domain/weather_grid.dart';
import '../bloc/map_bloc.dart' hide MapEvent;
import '../map_style.dart';
import 'map_markers.dart';
import 'weather_overlay.dart';

/// flutter_map with OpenFreeMap vector tiles in the Osmon night style, the
/// weather field on top, and value chips for the regional centres.
class OsmonMap extends StatefulWidget {
  const OsmonMap({
    super.key,
    required this.controller,
    required this.tint,
    this.initialZoom = 6,
    this.interactive = true,
  });

  final MapController controller;
  final Color tint;
  final double initialZoom;
  final bool interactive;

  static const String attribution =
      '© OpenFreeMap  © OpenMapTiles  © OpenStreetMap';
  static const double _minZoom = 3;
  static const double _maxZoom = 12;
  static const int _tileMaxZoom = 14;

  @override
  State<OsmonMap> createState() => _OsmonMapState();
}

class _OsmonMapState extends State<OsmonMap> {
  Future<vtr.Theme>? _theme;
  String? _themeLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language =
        context.read<SettingsBloc>().state.settings.languageCode ?? 'uz';
    if (language != _themeLanguage) {
      _themeLanguage = language;
      _theme = MapStyle.load(language);
    }
  }

  void _reportViewport() {
    final bounds = widget.controller.camera.visibleBounds;
    context.read<MapBloc>().add(
      MapViewportChanged(
        GeoBounds(
          south: bounds.south,
          west: bounds.west,
          north: bounds.north,
          east: bounds.east,
        ),
      ),
    );
  }

  void _onMapEvent(MapEvent event) {
    final settled =
        event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventDoubleTapZoomEnd ||
        event is MapEventScrollWheelZoom ||
        event is MapEventRotateEnd ||
        event is MapEventNonRotatedSizeChange;
    if (settled) _reportViewport();
  }

  @override
  Widget build(BuildContext context) {
    final formats = formatsOf(context);
    final l10n = context.l10n;
    return BlocConsumer<MapBloc, MapState>(
      listenWhen: (previous, current) =>
          previous.focusRevision != current.focusRevision,
      listener: (context, state) {
        final focus = state.focus;
        if (focus == null) return;
        widget.controller.move(
          LatLng(focus.point.latitude, focus.point.longitude),
          widget.controller.camera.zoom,
        );
      },
      builder: (context, state) {
        final focus = state.focus;
        final template = state.tileTemplate;
        return FlutterMap(
          mapController: widget.controller,
          options: MapOptions(
            initialCenter: focus == null
                ? const LatLng(41.3, 64.6)
                : LatLng(focus.point.latitude, focus.point.longitude),
            initialZoom: widget.initialZoom,
            minZoom: OsmonMap._minZoom,
            maxZoom: OsmonMap._maxZoom,
            backgroundColor: OsmonColors.ink,
            onMapReady: _reportViewport,
            onMapEvent: _onMapEvent,
            interactionOptions: InteractionOptions(
              flags: widget.interactive
                  ? InteractiveFlag.all & ~InteractiveFlag.rotate
                  : InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: <Widget>[
            if (template != null)
              FutureBuilder<vtr.Theme>(
                future: _theme,
                builder: (context, snapshot) {
                  final theme = snapshot.data;
                  if (theme == null) return const SizedBox.shrink();
                  return VectorTileLayer(
                    theme: theme,
                    tileProviders: TileProviders(<String, VectorTileProvider>{
                      'openmaptiles': NetworkVectorTileProvider(
                        urlTemplate: template,
                        maximumZoom: OsmonMap._tileMaxZoom,
                      ),
                    }),
                  );
                },
              ),
            if (state.grid case final grid?)
              WeatherOverlay(grid: grid, layer: state.layer, step: state.step),
            MapMarkers(
              grid: state.grid,
              layer: state.layer,
              step: state.step,
              focus: focus,
              formats: formats,
              tint: widget.tint,
              millimetresLabel: l10n.unitMm,
            ),
            const _Attribution(),
          ],
        );
      },
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomLeft,
    child: Padding(
      padding: const EdgeInsets.all(OsmonSpace.s8),
      child: Text(
        OsmonMap.attribution,
        style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
      ),
    ),
  );
}
