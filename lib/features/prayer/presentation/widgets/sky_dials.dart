import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';

/// A dashed half-ellipse from sunrise to sunset with the sun at [progress].
class SunArc extends StatelessWidget {
  const SunArc({super.key, required this.progress, required this.tint});

  /// 0 at sunrise, 1 at sunset; null when the sun is down.
  final double? progress;
  final Color tint;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: OsmonSize.sunArcHeight,
    width: double.infinity,
    child: CustomPaint(
      painter: _SunArcPainter(progress: progress, tint: tint),
    ),
  );
}

final class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({required this.progress, required this.tint});

  final double? progress;
  final Color tint;

  static const double _sunRadius = 8;
  static const double _dash = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _sunRadius,
      _sunRadius,
      size.width - _sunRadius * 2,
      (size.height - _sunRadius) * 2,
    );
    final arcPaint = Paint()
      ..color = OsmonColors.glassStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = OsmonSize.strokeIcon;
    // Dashes along the upper half of the ellipse.
    const segments = 36;
    for (var i = 0; i < segments; i += 2) {
      final start = math.pi + math.pi * i / segments;
      canvas.drawArc(rect, start, math.pi / segments, false, arcPaint);
    }
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      Paint()
        ..color = OsmonColors.divider
        ..strokeWidth = OsmonSize.strokeHairline,
    );
    final value = progress;
    if (value == null) return;
    final angle = math.pi + math.pi * value;
    final center = Offset(
      rect.center.dx + rect.width / 2 * math.cos(angle),
      rect.center.dy + rect.height / 2 * math.sin(angle),
    );
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * value,
      false,
      Paint()
        ..color = tint.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = OsmonSize.strokeIcon + 0.6,
    );
    canvas.drawCircle(
      center,
      _sunRadius * 2.4,
      Paint()..color = OsmonColors.sunCore.withValues(alpha: 0.25),
    );
    canvas.drawCircle(center, _sunRadius, Paint()..color = OsmonColors.sunCore);
    canvas.drawCircle(center, _dash / 3, Paint()..color = OsmonColors.gold);
  }

  @override
  bool shouldRepaint(_SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.tint != tint;
}

/// The moon disc lit to match its phase, terminator on the correct side.
class MoonDisc extends StatelessWidget {
  const MoonDisc({
    super.key,
    required this.illumination,
    required this.isWaxing,
  });

  final double illumination;
  final bool isWaxing;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: OsmonSize.moonDisc,
    child: CustomPaint(
      painter: _MoonPainter(illumination: illumination, isWaxing: isWaxing),
    ),
  );
}

final class _MoonPainter extends CustomPainter {
  const _MoonPainter({required this.illumination, required this.isWaxing});

  final double illumination;
  final bool isWaxing;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, radius, Paint()..color = OsmonColors.inkRaised);
    // The lit part is a half disc plus/minus an ellipse whose width follows
    // the illuminated fraction.
    final lit = Path();
    final rect = Rect.fromCircle(center: center, radius: radius);
    final terminatorWidth = radius * (1 - 2 * illumination).abs();
    final terminator = Rect.fromCenter(
      center: center,
      width: terminatorWidth * 2,
      height: radius * 2,
    );
    final litRight = isWaxing;
    lit.addArc(rect, litRight ? -math.pi / 2 : math.pi / 2, math.pi);
    final ellipse = Path()..addOval(terminator);
    final half = Path()
      ..addRect(
        litRight
            ? Rect.fromLTWH(center.dx, 0, radius, size.height)
            : Rect.fromLTWH(0, 0, radius, size.height),
      );
    final shape = illumination > 0.5
        ? Path.combine(PathOperation.union, lit, ellipse)
        : Path.combine(
            PathOperation.difference,
            lit,
            Path.combine(PathOperation.intersect, ellipse, half),
          );
    canvas.drawPath(shape, Paint()..color = OsmonColors.moonCore);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = OsmonColors.glassStroke
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_MoonPainter oldDelegate) =>
      oldDelegate.illumination != illumination ||
      oldDelegate.isWaxing != isWaxing;
}
