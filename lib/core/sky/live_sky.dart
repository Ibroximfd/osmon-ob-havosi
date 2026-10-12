import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'sky_painter.dart';
import 'sky_palette.dart';
import 'sky_scene.dart';
import 'sky_simulation.dart';

/// The animated sky for one [scene]. Stops ticking when [animate] is false
/// (the user's "live background" or the system "reduce motion" setting) and
/// then paints a single still frame.
class LiveSky extends StatefulWidget {
  const LiveSky({
    super.key,
    required this.scene,
    this.animate = true,
    this.batterySaver = false,
    this.seed = 7,
  });

  final SkyScene scene;
  final bool animate;

  /// Halves particles and caps the frame rate at 30 fps.
  final bool batterySaver;

  /// Fixed seeds keep store screenshots and golden tests reproducible.
  final int seed;

  @override
  State<LiveSky> createState() => _LiveSkyState();
}

class _LiveSkyState extends State<LiveSky> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  SkySimulation? _simulation;
  Duration _lastFrame = Duration.zero;

  Duration get _frameInterval => widget.batterySaver
      ? const Duration(microseconds: 33333)
      : const Duration(microseconds: 16666);

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(LiveSky oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene ||
        oldWidget.batterySaver != widget.batterySaver) {
      _simulation = null;
    }
    _syncTicker();
  }

  void _syncTicker() {
    if (widget.animate && !_ticker.isActive) {
      _lastFrame = Duration.zero;
      _ticker.start();
    } else if (!widget.animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastFrame;
    if (delta < _frameInterval) return;
    _lastFrame = elapsed;
    final simulation = _simulation;
    if (simulation == null) return;
    // Clamp so a resumed app does not fast-forward the particles.
    simulation.advance(math.min(delta.inMicroseconds / 1e6, 0.05));
    _frame.value++;
  }

  SkySimulation _simulationFor(Size size) {
    final existing = _simulation;
    if (existing != null && existing.size == size) return existing;
    return _simulation = SkySimulation(
      palette: widget.scene.palette,
      size: size,
      random: math.Random(widget.seed),
      density: widget.batterySaver ? 0.5 : 1,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: constraints.biggest,
        painter: SkyPainter(
          simulation: _simulationFor(constraints.biggest),
          repaint: _frame,
        ),
      ),
    ),
  );
}
