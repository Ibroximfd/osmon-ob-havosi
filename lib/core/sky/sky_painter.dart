import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/osmon_colors.dart';
import 'sky_palette.dart';
import 'sky_simulation.dart';

/// Paints one frame of a [SkySimulation]. Shaders are cached per size; the
/// particle systems are batched into a handful of `drawPoints` calls so a
/// full storm stays well inside a frame budget.
final class SkyPainter extends CustomPainter {
  SkyPainter({required this.simulation, required super.repaint});

  final SkySimulation simulation;

  ui.Shader? _gradient;
  Size? _gradientSize;

  // Kept small and high so the disc stays behind the header, not behind
  // the cards people read.
  static const double _sunRadius = 26;
  static const double _moonRadius = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = simulation.palette;
    _paintGradient(canvas, size, palette);
    if (simulation.stars.isNotEmpty) _paintStars(canvas);
    _paintBody(canvas, size, palette.body);
    _paintClouds(canvas, palette.cloudTone);
    if (palette.fogBands > 0) _paintFog(canvas, size, palette.fogBands);
    _paintParticles(canvas, palette.particles);
    if (simulation.flash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = OsmonColors.lightning.withValues(
            alpha: simulation.flash * 0.5,
          ),
      );
    }
  }

  void _paintGradient(Canvas canvas, Size size, SkyPalette palette) {
    if (_gradient == null || _gradientSize != size) {
      _gradient = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width * 0.35, size.height),
        palette.gradient,
        const <double>[0, 0.52, 1],
      );
      _gradientSize = size;
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = _gradient);
  }

  void _paintStars(Canvas canvas) {
    final paint = Paint()..color = OsmonColors.star;
    for (final star in simulation.stars) {
      final twinkle =
          0.45 + 0.55 * math.sin(simulation.time * 0.72 + star.phase).abs();
      paint.color = OsmonColors.star.withValues(alpha: twinkle * 0.9);
      canvas.drawCircle(star.position, star.radius, paint);
    }
  }

  void _paintBody(Canvas canvas, Size size, CelestialBody body) {
    if (body == CelestialBody.none) return;
    final isMoon = body == CelestialBody.moon;
    final center = Offset(
      size.width * 0.8,
      size.height * (body == CelestialBody.lowSun ? 0.86 : 0.15),
    );
    final radius = isMoon ? _moonRadius : _sunRadius;
    final pulse = isMoon ? 1.0 : 1 + math.sin(simulation.time * 1.1) * 0.05;
    final haloRadius = radius * 4.2 * pulse;
    final core = isMoon ? OsmonColors.moonCore : OsmonColors.sunCore;
    canvas.drawCircle(
      center,
      haloRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          haloRadius,
          <Color>[
            core.withValues(alpha: isMoon ? 0.7 : 0.95),
            core.withValues(alpha: isMoon ? 0.16 : 0.3),
            core.withValues(alpha: 0),
          ],
          const <double>[0, 0.26, 1],
        ),
    );
    // Slightly translucent so the disc never fights the text on top of it.
    final disc = Paint()..color = core.withValues(alpha: 0.85);
    if (!isMoon) {
      canvas.drawCircle(center, radius, disc);
    } else {
      // A crescent: cut a slightly offset disc out of the moon.
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: radius),
        Paint(),
      );
      canvas.drawCircle(center, radius, disc);
      canvas.drawCircle(
        center.translate(radius * 0.45, -radius * 0.32),
        radius * 0.88,
        Paint()..blendMode = BlendMode.dstOut,
      );
      canvas.restore();
    }
  }

  void _paintClouds(Canvas canvas, Color tone) {
    for (final cloud in simulation.clouds) {
      final center = Offset(cloud.x, cloud.y);
      canvas.drawCircle(
        center,
        cloud.radius,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            cloud.radius,
            <Color>[
              tone.withValues(alpha: cloud.opacity),
              tone.withValues(alpha: 0),
            ],
            const <double>[0.16, 1],
          ),
      );
    }
  }

  void _paintFog(Canvas canvas, Size size, int bands) {
    for (var i = 0; i < bands; i++) {
      final y =
          size.height * (0.26 + i * 0.15) +
          math.sin(simulation.time * 0.36 + i) * 7;
      final rect = Rect.fromLTWH(0, y - 26, size.width, 52);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            <Color>[
              OsmonColors.fogBand.withValues(alpha: 0),
              OsmonColors.fogBand.withValues(alpha: 0.3),
              OsmonColors.fogBand.withValues(alpha: 0),
            ],
            const <double>[0, 0.5, 1],
          ),
      );
    }
  }

  void _paintParticles(Canvas canvas, ParticleKind kind) {
    switch (kind) {
      case ParticleKind.rain || ParticleKind.heavyRain:
        _paintRain(canvas, heavy: kind == ParticleKind.heavyRain);
      case ParticleKind.snow:
        _paintDots(canvas, OsmonColors.snowFlake, 2.1, swayAmplitude: 7);
      case ParticleKind.dust:
        _paintDots(canvas, OsmonColors.dustMote, 1.7, swayAmplitude: 5);
      case ParticleKind.none:
        break;
    }
  }

  /// Rain in three alpha buckets: one `drawPoints` call per bucket.
  void _paintRain(Canvas canvas, {required bool heavy}) {
    final buckets = <List<Offset>>[<Offset>[], <Offset>[], <Offset>[]];
    final length = heavy ? 17.0 : 12.0;
    for (final p in simulation.particles) {
      final bucket = (p.scale * 2.99).floor().clamp(0, 2);
      final dropLength = length * p.scale;
      buckets[bucket]
        ..add(Offset(p.x, p.y))
        ..add(Offset(p.x - dropLength * 0.26, p.y + dropLength));
    }
    for (var i = 0; i < buckets.length; i++) {
      canvas.drawPoints(
        ui.PointMode.lines,
        buckets[i],
        Paint()
          ..color = OsmonColors.rainDrop.withValues(alpha: 0.26 + i * 0.16)
          ..strokeWidth = 0.6 + i * 0.35
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintDots(
    Canvas canvas,
    Color color,
    double maxRadius, {
    required double swayAmplitude,
  }) {
    final buckets = <List<Offset>>[<Offset>[], <Offset>[], <Offset>[]];
    for (final p in simulation.particles) {
      final bucket = (p.scale * 2.99).floor().clamp(0, 2);
      final sway = math.sin(simulation.time * 1.1 + p.phase) * swayAmplitude;
      buckets[bucket].add(Offset(p.x + sway, p.y));
    }
    for (var i = 0; i < buckets.length; i++) {
      canvas.drawPoints(
        ui.PointMode.points,
        buckets[i],
        Paint()
          ..color = color.withValues(alpha: 0.35 + i * 0.22)
          ..strokeWidth = maxRadius * (0.8 + i * 0.6)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(SkyPainter oldDelegate) =>
      oldDelegate.simulation != simulation;
}
