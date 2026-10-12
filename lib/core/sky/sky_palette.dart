import 'package:flutter/painting.dart';

import '../theme/osmon_colors.dart';
import 'sky_scene.dart';

extension SkyScenePalette on SkyScene {
  SkyPalette get palette => switch (this) {
    SkyScene.clearDay => const SkyPalette(
      gradient: <Color>[
        Color(0xFF0E4D8F),
        Color(0xFF2E8FCB),
        Color(0xFF9BD4E8),
      ],
      tint: Color(0xFFFFC75A),
      body: CelestialBody.sun,
      cloudCover: 0.12,
      cloudTone: Color(0xFFFFFFFF),
    ),
    SkyScene.twilight => const SkyPalette(
      gradient: <Color>[
        Color(0xFF23305E),
        Color(0xFF8A4E6E),
        Color(0xFFF2A65A),
      ],
      tint: Color(0xFFFFB86B),
      body: CelestialBody.lowSun,
      cloudCover: 0.25,
      cloudTone: Color(0xFFFFD2B0),
      stars: 30,
    ),
    SkyScene.clearNight => const SkyPalette(
      gradient: <Color>[
        Color(0xFF03060F),
        Color(0xFF0B1830),
        Color(0xFF1D3A5C),
      ],
      tint: Color(0xFF9BB8E8),
      body: CelestialBody.moon,
      cloudCover: 0.1,
      cloudTone: Color(0xFFB8C8E0),
      stars: 130,
    ),
    SkyScene.cloudyDay => const SkyPalette(
      gradient: <Color>[
        Color(0xFF2C4B66),
        Color(0xFF55768F),
        Color(0xFF9FB4C4),
      ],
      tint: Color(0xFF7FC6DC),
      body: CelestialBody.sun,
      cloudCover: 0.8,
      cloudTone: Color(0xFFFFFFFF),
    ),
    SkyScene.cloudyNight => const SkyPalette(
      gradient: <Color>[
        Color(0xFF070C17),
        Color(0xFF162236),
        Color(0xFF34465E),
      ],
      tint: Color(0xFF8FA9D6),
      body: CelestialBody.moon,
      cloudCover: 0.8,
      cloudTone: Color(0xFF8C9BB3),
      stars: 40,
    ),
    SkyScene.rain => const SkyPalette(
      gradient: <Color>[
        Color(0xFF101D2E),
        Color(0xFF21384F),
        Color(0xFF3C5E74),
      ],
      tint: Color(0xFF5FD0E8),
      cloudCover: 0.95,
      cloudTone: Color(0xFF96ACC2),
      particles: ParticleKind.rain,
      particleCount: 150,
    ),
    SkyScene.storm => const SkyPalette(
      gradient: <Color>[
        Color(0xFF080E1A),
        Color(0xFF17212F),
        Color(0xFF2B3A4C),
      ],
      tint: Color(0xFFF0B33F),
      cloudCover: 1,
      cloudTone: Color(0xFF7C8DA3),
      particles: ParticleKind.heavyRain,
      particleCount: 220,
      lightning: true,
    ),
    SkyScene.snow => const SkyPalette(
      gradient: <Color>[
        Color(0xFF1B2740),
        Color(0xFF3A4C6B),
        Color(0xFF8E9FBA),
      ],
      tint: Color(0xFFBFE3F2),
      cloudCover: 0.9,
      cloudTone: Color(0xFFDDE6F2),
      particles: ParticleKind.snow,
      particleCount: 110,
    ),
    SkyScene.fog => const SkyPalette(
      gradient: <Color>[
        Color(0xFF2A3540),
        Color(0xFF4E5C68),
        Color(0xFF9AA5AD),
      ],
      tint: Color(0xFFB9C8D2),
      cloudCover: 0.6,
      cloudTone: Color(0xFFE6ECF0),
      fogBands: 5,
    ),
    SkyScene.dust => const SkyPalette(
      gradient: <Color>[
        Color(0xFF4A3418),
        Color(0xFF8A6327),
        Color(0xFFC79A4A),
      ],
      tint: Color(0xFFF0C566),
      cloudCover: 0.5,
      cloudTone: Color(0xFFD6B06E),
      particles: ParticleKind.dust,
      particleCount: 170,
    ),
  };
}

enum CelestialBody { none, sun, lowSun, moon }

enum ParticleKind { none, rain, heavyRain, snow, dust }

final class SkyPalette {
  const SkyPalette({
    required this.gradient,
    required this.tint,
    required this.cloudTone,
    this.body = CelestialBody.none,
    this.cloudCover = 0,
    this.stars = 0,
    this.particles = ParticleKind.none,
    this.particleCount = 0,
    this.lightning = false,
    this.fogBands = 0,
  });

  /// Top, middle and bottom of the sky gradient.
  final List<Color> gradient;

  /// Accent for in-app highlights while this scene is on screen.
  final Color tint;
  final Color cloudTone;
  final CelestialBody body;

  /// 0–1: how many drifting cloud masses to draw.
  final double cloudCover;
  final int stars;
  final ParticleKind particles;
  final int particleCount;
  final bool lightning;
  final int fogBands;

  static const Color fallbackTint = OsmonColors.accent;
}
