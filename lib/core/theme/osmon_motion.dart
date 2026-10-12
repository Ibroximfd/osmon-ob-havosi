import 'package:flutter/animation.dart';

/// Motion tokens. Durations are short; the sky is the only slow thing.
abstract final class OsmonMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration sceneCrossfade = Duration(milliseconds: 900);
  static const Duration stagger = Duration(milliseconds: 40);
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const Duration mapDebounce = Duration(milliseconds: 450);
  static const Duration clockTick = Duration(seconds: 30);
  static const Duration radarFrame = Duration(milliseconds: 700);

  static const Curve emphasized = Cubic(0.2, 0.8, 0.25, 1);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;

  /// Vertical travel of content rising into view.
  static const double riseOffset = 0.04;
}
