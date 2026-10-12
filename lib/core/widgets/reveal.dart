import 'package:flutter/widgets.dart';

import '../theme/osmon_motion.dart';

/// Rises and fades a child into place once, [order] steps after its
/// siblings. Starts from a visible resting state when motion is reduced.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.order = 0});

  final Widget child;
  final int order;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OsmonMotion.slow,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: OsmonMotion.emphasized,
  );

  static const int _maxStaggeredItems = 10;

  @override
  void initState() {
    super.initState();
    final delay =
        OsmonMotion.stagger * widget.order.clamp(0, _maxStaggeredItems);
    Future<void>.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, OsmonMotion.riseOffset * 4),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
