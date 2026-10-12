import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_motion.dart';
import '../theme/osmon_spacing.dart';

/// One shimmer clock for a whole skeleton screen, so twenty blocks share a
/// single animation controller instead of owning one each.
class ShimmerScope extends StatefulWidget {
  const ShimmerScope({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OsmonMotion.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ShimmerClock(animation: _controller, child: widget.child);
}

class _ShimmerClock extends InheritedNotifier<Animation<double>> {
  const _ShimmerClock({
    required Animation<double> animation,
    required super.child,
  }) : super(notifier: animation);

  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerClock>()?.notifier;
}

/// A placeholder block shaped like the content it stands in for.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = OsmonRadius.md,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final animation = _ShimmerClock.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pulse = animation == null || reduceMotion
        ? 0.5
        : (1 - (animation.value * 2 - 1).abs());
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Color.lerp(
          OsmonColors.glassFill,
          OsmonColors.glassFillStrong,
          pulse,
        ),
      ),
    );
  }
}
