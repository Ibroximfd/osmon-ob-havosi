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
///
/// The base map is built once per style and tile source; grid loads and
/// playback steps only rebuild the weather layers above it.
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
  String? _themeLanguage;
  vtr.Theme? _theme;
  Widget? _baseTiles;
  String? _baseTemplate;
  vtr.Theme? _baseTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language =
        context.read<SettingsBloc>().state.settings.languageCode ?? 'uz';
    if (language == _themeLanguage) return;
    _themeLanguage = language;
    MapStyle.load(language).then((theme) {
      if (mounted && language == _themeLanguage) {
        setState(() => _theme = theme);
      }
    });
  }

  /// Same instance while the style and source stay put, so Flutter skips
  /// the tile layer entirely when the parent rebuilds.
  Widget? _tilesFor(String? template) {
    final theme = _theme;
    if (template == null || theme == null) return null;
    if (template != _baseTemplate || theme != _baseTheme) {
      _baseTemplate = template;
      _baseTheme = theme;
      _baseTiles = VectorTileLayer(
        theme: theme,
        // OpenMapTiles are cut for 512 px: one tile a zoom level lower
        // covers what four default-sized tiles would, at a quarter of the
        // decoding and rendering work.
        tileOffset: TileOffset.mapbox,
        tileProviders: TileProviders(<String, VectorTileProvider>{
          'openmaptiles': NetworkVectorTileProvider(
            urlTemplate: template,
            maximumZoom: OsmonMap._tileMaxZoom,
          ),
        }),
      );
    }
    return _baseTiles;
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
  Widget build(BuildContext context) => BlocListener<MapBloc, MapState>(
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
    child: BlocSelector<MapBloc, MapState, String?>(
      selector: (state) => state.tileTemplate,
      builder: (context, template) {
        final focus = context.read<MapBloc>().state.focus;
        final tiles = _tilesFor(template);
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
            ?tiles,
            _WeatherLayers(tint: widget.tint),
            const _Attribution(),
          ],
        );
      },
    ),
  );
}

/// The weather field and the value chips — the only map layers that change
/// with grid loads and playback steps.
class _WeatherLayers extends StatelessWidget {
  const _WeatherLayers({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    final formats = formatsOf(context);
    final millimetres = context.l10n.unitMm;
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
          previous.grid != current.grid ||
          previous.layer != current.layer ||
          previous.step != current.step ||
          previous.focus != current.focus,
      builder: (context, state) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (state.grid case final grid?)
            WeatherOverlay(grid: grid, layer: state.layer, step: state.step),
          MapMarkers(
            grid: state.grid,
            layer: state.layer,
            step: state.step,
            focus: state.focus,
            formats: formats,
            tint: tint,
            millimetresLabel: millimetres,
          ),
        ],
      ),
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
