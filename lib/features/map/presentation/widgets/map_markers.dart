import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/domain/place.dart';
import '../../../../core/format/formats.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../domain/weather_grid.dart';

/// Value chips for the named regional centres plus the user's own place.
class MapMarkers extends StatelessWidget {
  const MapMarkers({
    super.key,
    required this.grid,
    required this.layer,
    required this.step,
    required this.focus,
    required this.formats,
    required this.tint,
    required this.millimetresLabel,
  });

  final WeatherGrid? grid;
  final MapLayer layer;
  final int step;
  final Place? focus;
  final Formats formats;
  final Color tint;
  final String millimetresLabel;

  static const Size _chip = Size(76, 40);
  static const double _focusDot = 18;

  String? _value(GridCell cell) => switch (layer) {
    MapLayer.temperature => formats.temperature(cell.temperature),
    MapLayer.precipitation => () {
      final steps = cell.precipitationSteps;
      final rate = (step < steps.length ? steps[step] : 0) * 4;
      return rate < 0.1 ? null : '${rate.toStringAsFixed(1)} $millimetresLabel';
    }(),
    MapLayer.wind => formats.windValue(cell.windSpeed),
    MapLayer.clouds => formats.percent(cell.cloudCover),
    MapLayer.airQuality => cell.usAqi?.round().toString(),
  };

  @override
  Widget build(BuildContext context) {
    final named = grid?.namedCells ?? const <GridCell>[];
    final own = focus;
    return MarkerLayer(
      markers: <Marker>[
        for (final cell in named)
          if (_value(cell) case final value?)
            Marker(
              point: LatLng(cell.point.latitude, cell.point.longitude),
              width: _chip.width,
              height: _chip.height,
              child: _ValueChip(value: value, name: cell.place!.name),
            ),
        if (own != null)
          Marker(
            point: LatLng(own.point.latitude, own.point.longitude),
            width: _focusDot * 2,
            height: _focusDot * 2,
            child: _FocusDot(tint: tint),
          ),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.value, required this.name});

  final String value;
  final String name;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: OsmonColors.inkSheet,
      borderRadius: BorderRadius.circular(OsmonRadius.sm),
      border: Border.all(color: OsmonColors.glassStroke),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: OsmonSpace.s4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(value, style: OsmonType.captionStrong, maxLines: 1),
          Text(
            name,
            style: OsmonType.micro.copyWith(color: OsmonColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _FocusDot extends StatelessWidget {
  const _FocusDot({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: MapMarkers._focusDot,
      height: MapMarkers._focusDot,
      decoration: BoxDecoration(
        color: tint,
        shape: BoxShape.circle,
        border: Border.all(color: OsmonColors.textPrimary, width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tint.withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: 4,
          ),
        ],
      ),
    ),
  );
}
