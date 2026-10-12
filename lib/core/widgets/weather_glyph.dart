import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../domain/weather_condition.dart';
import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';

/// The app's own weather icon set: one stroke weight, gold for heat and
/// light, turquoise for water and air, white cloud masses that read on any
/// sky. Drawn in a 24-unit box and scaled to [size].
enum GlyphKind {
  sun,
  moon,
  partlyCloudyDay,
  partlyCloudyNight,
  cloud,
  drizzle,
  rain,
  storm,
  snow,
  fog,
  dust,
  wind;

  static GlyphKind of(WeatherCondition condition, {required bool isDay}) =>
      switch (condition) {
        WeatherCondition.clear ||
        WeatherCondition.mainlyClear => isDay ? sun : moon,
        WeatherCondition.partlyCloudy =>
          isDay ? partlyCloudyDay : partlyCloudyNight,
        WeatherCondition.overcast => cloud,
        WeatherCondition.fog => fog,
        WeatherCondition.drizzle || WeatherCondition.freezingDrizzle => drizzle,
        WeatherCondition.rain ||
        WeatherCondition.heavyRain ||
        WeatherCondition.freezingRain ||
        WeatherCondition.rainShowers => rain,
        WeatherCondition.snow ||
        WeatherCondition.heavySnow ||
        WeatherCondition.snowShowers => snow,
        WeatherCondition.thunderstorm ||
        WeatherCondition.thunderstormHail => storm,
      };
}

class WeatherGlyph extends StatefulWidget {
  const WeatherGlyph({
    super.key,
    required this.kind,
    this.size = OsmonSize.glyphMd,
    this.animate = false,
    this.semanticLabel,
  });

  final GlyphKind kind;
  final double size;

  /// Only the hero glyph animates; list rows stay still to save frames.
  final bool animate;
  final String? semanticLabel;

  @override
  State<WeatherGlyph> createState() => _WeatherGlyphState();
}

class _WeatherGlyphState extends State<WeatherGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(WeatherGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.semanticLabel,
    excludeSemantics: widget.semanticLabel == null,
    child: SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(
        painter: _GlyphPainter(
          kind: widget.kind,
          phase: _controller,
          still: !widget.animate || MediaQuery.disableAnimationsOf(context),
        ),
      ),
    ),
  );
}

final class _GlyphPainter extends CustomPainter {
  _GlyphPainter({required this.kind, required this.phase, required this.still})
    : super(repaint: phase);

  final GlyphKind kind;
  final Animation<double> phase;
  final bool still;

  static const double _box = 24;

  double get _t => still ? 0.25 : phase.value;

  Paint _stroke(Color color, [double width = OsmonSize.strokeIcon]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _fill(Color color) => Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _box);
    switch (kind) {
      case GlyphKind.sun:
        _sun(canvas, const Offset(12, 12), 4.2, rays: true);
      case GlyphKind.moon:
        _moon(canvas, const Offset(12, 12), 7);
      case GlyphKind.partlyCloudyDay:
        _sun(canvas, const Offset(8.6, 8.4), 3.2, rays: true, rayScale: 0.7);
        _cloud(canvas, dx: _drift);
      case GlyphKind.partlyCloudyNight:
        _moon(canvas, const Offset(9, 8.6), 4.4);
        _cloud(canvas, dx: _drift);
      case GlyphKind.cloud:
        _cloud(canvas, dx: _drift, dy: -1.5);
      case GlyphKind.drizzle:
        _cloud(canvas, dy: -3);
        _drops(canvas, count: 2, length: 1.6);
      case GlyphKind.rain:
        _cloud(canvas, dy: -3);
        _drops(canvas, count: 3, length: 2.6);
      case GlyphKind.storm:
        _cloud(canvas, dy: -3.5);
        _bolt(canvas);
      case GlyphKind.snow:
        _cloud(canvas, dy: -3.5);
        _flakes(canvas);
      case GlyphKind.fog:
        _fog(canvas);
      case GlyphKind.dust:
        _dust(canvas);
      case GlyphKind.wind:
        _wind(canvas, OsmonColors.textPrimary);
    }
    canvas.restore();
  }

  double get _drift => math.sin(_t * math.pi * 2) * 1.0;

  void _sun(
    Canvas canvas,
    Offset center,
    double radius, {
    required bool rays,
    double rayScale = 1,
  }) {
    canvas.drawCircle(center, radius, _fill(OsmonColors.gold));
    if (!rays) return;
    final rayPaint = _stroke(OsmonColors.gold);
    final rotation = _t * math.pi * 2 / 6;
    for (var i = 0; i < 8; i++) {
      final angle = rotation + i * math.pi / 4;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius + 2.2 * rayScale),
        center + direction * (radius + 4.4 * rayScale),
        rayPaint,
      );
    }
  }

  void _moon(Canvas canvas, Offset center, double radius) {
    canvas.saveLayer(
      Rect.fromCircle(center: center, radius: radius + 1),
      Paint(),
    );
    canvas.drawCircle(center, radius, _fill(OsmonColors.moonCore));
    canvas.drawCircle(
      center.translate(radius * 0.5, -radius * 0.36),
      radius * 0.86,
      Paint()..blendMode = BlendMode.dstOut,
    );
    canvas.restore();
  }

  void _cloud(Canvas canvas, {double dx = 0, double dy = 0}) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(8 + dx, 15.6 + dy), radius: 3.7))
      ..addOval(
        Rect.fromCircle(center: Offset(12.6 + dx, 12.2 + dy), radius: 4.9),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(17.2 + dx, 15.4 + dy), radius: 3.4),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(8 + dx, 14.2 + dy, 17.4 + dx, 19.3 + dy),
          const Radius.circular(2),
        ),
      );
    canvas.drawPath(
      path,
      _fill(OsmonColors.textPrimary.withValues(alpha: .94)),
    );
  }

  void _drops(Canvas canvas, {required int count, required double length}) {
    final paint = _stroke(OsmonColors.accent, 1.8);
    for (var i = 0; i < count; i++) {
      final x = count == 2 ? 10.0 + i * 4 : 8.5 + i * 3.5;
      final offset = ((_t * 3 + i / count) % 1) * 2.4;
      canvas.drawLine(
        Offset(x, 18 + offset),
        Offset(x - 0.6, 18 + offset + length),
        paint,
      );
    }
  }

  void _bolt(Canvas canvas) {
    final visible = still || (_t * 4 % 1) > 0.12;
    if (!visible) return;
    final path = Path()
      ..moveTo(13.2, 15)
      ..lineTo(10.2, 19.4)
      ..lineTo(13.2, 19.4)
      ..lineTo(11.6, 22.6);
    canvas.drawPath(path, _stroke(OsmonColors.gold, 1.9));
  }

  void _flakes(Canvas canvas) {
    final paint = _fill(OsmonColors.textPrimary);
    for (var i = 0; i < 3; i++) {
      final offset = ((_t * 2 + i / 3) % 1) * 2.6;
      canvas.drawCircle(Offset(8.6 + i * 3.4, 18.4 + offset), 1.05, paint);
    }
  }

  void _fog(Canvas canvas) {
    final paint = _stroke(OsmonColors.textPrimary.withValues(alpha: .9), 1.9);
    final sway = math.sin(_t * math.pi * 2) * 1.2;
    canvas.drawLine(Offset(4 + sway, 8), Offset(18 + sway, 8), paint);
    canvas.drawLine(Offset(3 - sway, 12.5), Offset(21 - sway, 12.5), paint);
    canvas.drawLine(Offset(5 + sway, 17), Offset(17 + sway, 17), paint);
  }

  void _dust(Canvas canvas) {
    _wind(canvas, OsmonColors.gold);
    final paint = _fill(OsmonColors.gold);
    canvas.drawCircle(const Offset(6, 20.5), 0.9, paint);
    canvas.drawCircle(const Offset(11, 20), 0.7, paint);
    canvas.drawCircle(const Offset(15.5, 21), 0.6, paint);
  }

  void _wind(Canvas canvas, Color color) {
    final paint = _stroke(color);
    final sway = math.sin(_t * math.pi * 2) * 0.9;
    final top = Path()
      ..moveTo(3, 8.5 + sway)
      ..lineTo(13, 8.5 + sway)
      ..arcToPoint(
        Offset(10.6, 6.1 + sway),
        radius: const Radius.circular(2.4),
        clockwise: false,
      );
    final middle = Path()
      ..moveTo(3, 13)
      ..lineTo(17, 13)
      ..arcToPoint(
        const Offset(14.4, 15.6),
        radius: const Radius.circular(2.6),
      );
    canvas.drawPath(top, paint);
    canvas.drawPath(middle, paint);
    canvas.drawLine(Offset(3, 17.5 - sway), Offset(11, 17.5 - sway), paint);
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.still != still;
}
