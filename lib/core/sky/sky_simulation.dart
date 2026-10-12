import 'dart:math' as math;
import 'dart:ui';

import 'sky_palette.dart';

/// Mutable particle state for one scene at one canvas size. Kept apart from
/// the painter so it survives repaints and can be stepped deterministically
/// in tests.
final class SkySimulation {
  SkySimulation({
    required this.palette,
    required this.size,
    required math.Random random,
    double density = 1,
  }) : _random = random {
    _seed(density);
  }

  final SkyPalette palette;
  final Size size;
  final math.Random _random;

  final List<SkyParticle> particles = <SkyParticle>[];
  final List<SkyStar> stars = <SkyStar>[];
  final List<SkyCloud> clouds = <SkyCloud>[];

  /// Seconds since the simulation started; drives twinkle and drift phases.
  double time = 0;

  /// 0–1 brightness of the current lightning flash.
  double flash = 0;
  double _nextFlashIn = 2;

  static const int _maxClouds = 8;

  void _seed(double density) {
    final count = (palette.particleCount * density).round();
    for (var i = 0; i < count; i++) {
      particles.add(
        SkyParticle(
          x: _rand(-40, size.width + 40),
          y: _rand(-size.height, size.height),
          speed: _rand(0.5, 1),
          scale: _rand(0.4, 1),
          phase: _rand(0, math.pi * 2),
        ),
      );
    }
    for (var i = 0; i < palette.stars; i++) {
      stars.add(
        SkyStar(
          position: Offset(_rand(0, size.width), _rand(0, size.height * 0.6)),
          radius: _rand(0.4, 1.3),
          phase: _rand(0, math.pi * 2),
        ),
      );
    }
    final cloudCount = (palette.cloudCover * (_maxClouds - 1)).round() + 1;
    for (var i = 0; i < cloudCount; i++) {
      clouds.add(
        SkyCloud(
          x: _rand(-60, size.width + 60),
          y: _rand(size.height * 0.04, size.height * 0.5),
          radius: _rand(size.width * 0.14, size.width * 0.34),
          speed: _rand(3, 13),
          opacity: _rand(0.10, 0.30),
        ),
      );
    }
  }

  /// Advances the world by [dt] seconds.
  void advance(double dt) {
    time += dt;
    _advanceClouds(dt);
    _advanceParticles(dt);
    if (palette.lightning) _advanceLightning(dt);
  }

  void _advanceClouds(double dt) {
    for (final cloud in clouds) {
      cloud.x += cloud.speed * dt;
      if (cloud.x - cloud.radius * 2 > size.width) {
        cloud.x = -cloud.radius * 2;
      }
    }
  }

  void _advanceParticles(double dt) {
    final frames = dt * 60;
    for (final p in particles) {
      switch (palette.particles) {
        case ParticleKind.rain || ParticleKind.heavyRain:
          final fall =
              (palette.particles == ParticleKind.heavyRain ? 13 : 9) * p.speed;
          p.y += fall * frames;
          p.x -= fall * 0.26 * frames;
          if (p.y > size.height + 10) {
            p.y = -14;
            p.x = _rand(-30, size.width + 30);
          }
        case ParticleKind.snow:
          p.y += p.speed * 1.25 * frames;
          if (p.y > size.height + 6) {
            p.y = -8;
            p.x = _rand(0, size.width);
          }
        case ParticleKind.dust:
          p.x += p.speed * 3.1 * frames;
          if (p.x > size.width + 12) {
            p.x = -12;
            p.y = _rand(0, size.height);
          }
        case ParticleKind.none:
          break;
      }
    }
  }

  void _advanceLightning(double dt) {
    flash = math.max(0, flash - dt * 6.5);
    _nextFlashIn -= dt;
    if (_nextFlashIn <= 0) {
      flash = 1;
      _nextFlashIn = _rand(1.4, 3.6);
    }
  }

  double _rand(double min, double max) =>
      min + _random.nextDouble() * (max - min);
}

final class SkyParticle {
  SkyParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.scale,
    required this.phase,
  });

  double x;
  double y;
  final double speed;
  final double scale;
  final double phase;
}

final class SkyStar {
  const SkyStar({
    required this.position,
    required this.radius,
    required this.phase,
  });

  final Offset position;
  final double radius;
  final double phase;
}

final class SkyCloud {
  SkyCloud({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });

  double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
}
