import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/osmon_colors.dart';
import '../../domain/weather_grid.dart';
import 'weather_layer_colors.dart';

/// Paints the active weather field over the map: soft colour blobs for
/// scalar layers, arrows for wind. Re-projects on every camera change.
class WeatherOverlay extends StatelessWidget {
  const WeatherOverlay({
    super.key,
    required this.grid,
    required this.layer,
    required this.step,
  });

  final WeatherGrid grid;
  final MapLayer layer;
  final int step;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _OverlayPainter(
          cells: grid.cells,
          bounds: grid.bounds,
          project: (lat, lon) => camera.latLngToScreenOffset(LatLng(lat, lon)),
          layer: layer,
          step: step,
        ),
      ),
    );
  }
}

typedef _Projector = Offset Function(double latitude, double longitude);

final class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({
    required this.cells,
    required this.bounds,
    required this.project,
    required this.layer,
    required this.step,
  });

  final List<GridCell> cells;
  final GeoBounds bounds;
  final _Projector project;
  final MapLayer layer;
  final int step;

  /// Grid columns used by the repository; the blob radius follows from it.
  static const int _columns = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final west = project(bounds.north, bounds.west);
    final east = project(bounds.north, bounds.east);
    final radius = ((east.dx - west.dx).abs() / _columns) * 0.95;
    if (radius <= 0) return;
    for (final cell in cells) {
      final center = project(cell.point.latitude, cell.point.longitude);
      switch (layer) {
        case MapLayer.temperature:
          _blob(
            canvas,
            center,
            radius,
            WeatherLayerColors.temperature(cell.temperature),
            0.42,
          );
        case MapLayer.precipitation:
          final steps = cell.precipitationSteps;
          final amount = step < steps.length ? steps[step] : 0.0;
          if (amount < 0.05) continue;
          final rate = amount * 4;
          _blob(
            canvas,
            center,
            radius * (0.7 + math.min(rate, 10) / 25),
            WeatherLayerColors.precipitation(rate),
            0.62,
          );
        case MapLayer.clouds:
          _blob(
            canvas,
            center,
            radius,
            OsmonColors.textPrimary,
            cell.cloudCover / 100 * 0.45,
          );
        case MapLayer.airQuality:
          final aqi = cell.usAqi;
          if (aqi == null) continue;
          _blob(
            canvas,
            center,
            radius,
            WeatherLayerColors.airQuality(aqi),
            0.45,
          );
        case MapLayer.wind:
          _arrow(canvas, center, radius, cell);
      }
    }
  }

  void _blob(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(center, radius, <Color>[
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ]),
    );
  }

  /// Points where the wind goes (meteorological direction + 180°); longer
  /// and brighter as it strengthens.
  void _arrow(Canvas canvas, Offset center, double radius, GridCell cell) {
    final angle = (cell.windDirection + 180) * math.pi / 180;
    final strength = (cell.windSpeed / 40).clamp(0.2, 1.0);
    final length = radius * 0.55 * strength + radius * 0.15;
    final direction = Offset(math.sin(angle), -math.cos(angle));
    final tail = center - direction * length / 2;
    final head = center + direction * length / 2;
    final paint = Paint()
      ..color = OsmonColors.textPrimary.withValues(alpha: 0.35 + strength * 0.5)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, head, paint);
    final wing = length * 0.3;
    for (final side in <double>[0.5, -0.5]) {
      final back = Offset(
        math.sin(angle + math.pi + side),
        -math.cos(angle + math.pi + side),
      );
      canvas.drawLine(head, head + back * wing, paint);
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) => true;
}
