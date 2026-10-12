import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';

/// The glass surface every card sits on. Blur is opt-in: a backdrop filter
/// over an animated sky re-renders every frame, so only fixed chrome (the
/// nav bar, sheets) pays for it; scrolling cards use a translucent fill.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(OsmonSpace.s14),
    this.radius = OsmonRadius.lg,
    this.fill = OsmonColors.glassFill,
    this.stroke = OsmonColors.glassStroke,
    this.blur = false,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color fill;
  final Color stroke;
  final bool blur;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double _blurSigma = 18;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: stroke, width: OsmonSize.strokeHairline),
    );
    Widget surface = Material(
      color: fill,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              splashColor: OsmonColors.glassFillStrong,
              highlightColor: OsmonColors.glassFill,
              child: Padding(padding: padding, child: child),
            ),
    );
    if (blur) {
      surface = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: surface,
        ),
      );
    }
    if (semanticLabel == null) return surface;
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: surface,
    );
  }
}
