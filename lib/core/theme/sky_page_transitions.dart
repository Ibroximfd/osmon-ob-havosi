import 'package:flutter/material.dart';

import 'osmon_motion.dart';

/// Every page is transparent over the shared sky, so a sliding transition
/// would show two screens on top of each other. Pages fade through instead:
/// the outgoing one dissolves while the incoming one settles into place.
class SkyFadeTransitionsBuilder extends PageTransitionsBuilder {
  const SkyFadeTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: OsmonMotion.emphasized,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: OsmonMotion.standard,
    );
    return FadeTransition(
      opacity: ReverseAnimation(outgoing),
      child: FadeTransition(
        opacity: incoming,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, OsmonMotion.riseOffset),
            end: Offset.zero,
          ).animate(incoming),
          child: child,
        ),
      ),
    );
  }
}
