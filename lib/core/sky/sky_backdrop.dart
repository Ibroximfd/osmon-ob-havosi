import 'package:flutter/widgets.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_motion.dart';
import 'live_sky.dart';
import 'sky_scene.dart';

/// The sky behind every screen, with a readability veil on top. Scene
/// changes cross-fade so switching city never cuts abruptly.
class SkyBackdrop extends StatelessWidget {
  const SkyBackdrop({
    super.key,
    required this.scene,
    required this.child,
    this.animate = true,
    this.batterySaver = false,
  });

  final SkyScene scene;
  final bool animate;
  final bool batterySaver;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(color: OsmonColors.ink),
        AnimatedSwitcher(
          duration: OsmonMotion.sceneCrossfade,
          child: LiveSky(
            key: ValueKey<SkyScene>(scene),
            scene: scene,
            animate: animate && !reduceMotion,
            batterySaver: batterySaver,
          ),
        ),
        const _Veil(),
        child,
      ],
    );
  }
}

class _Veil extends StatelessWidget {
  const _Veil();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            OsmonColors.veilTop,
            OsmonColors.veilClear,
            OsmonColors.veilMid,
            OsmonColors.veilBottom,
          ],
          stops: <double>[0, 0.26, 0.58, 1],
        ),
      ),
    ),
  );
}
