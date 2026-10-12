import 'dart:math' as math;
import 'dart:ui';

/// The approved app icon ("Osmon halqasi", variant 2): a horizon ring that
/// runs from Samarkand turquoise to dome gold, the sun inside it, and the
/// line of the land under the sun. Drawn in a 512-unit box.
final class OsmonMark {
  const OsmonMark({this.withBackground = true, this.scale = 1});

  final bool withBackground;

  /// Shrinks the mark around the centre (adaptive icons need a safe zone).
  final double scale;

  static const Color _deep = Color(0xFF071A2E);
  static const Color _sea = Color(0xFF0F4C6B);
  static const Color _turquoise = Color(0xFF2FD0E8);
  static const Color _gold = Color(0xFFF0B33F);
  static const Color _sun = Color(0xFFF3C25A);
  static const Color _horizon = Color(0xFF9EE7F5);
  static const Color _highlight = Color(0xFFFFFFFF);

  static const double _box = 512;

  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _box, size.height / _box);
    if (withBackground) paintBackground(canvas);
    canvas.translate(_box / 2, _box / 2);
    canvas.scale(scale);
    canvas.translate(-_box / 2, -_box / 2);

    const center = Offset(256, 256);
    const radius = 150.0;
    const inner = 128.0;
    final ringRect = Rect.fromCircle(center: center, radius: radius);

    // Inside the ring: the sun half-risen over a calm horizon, so the mark
    // reads as "sky" at a glance and never as a profile avatar.
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: inner)),
    );
    canvas.drawCircle(
      center,
      inner,
      Paint()
        ..shader = Gradient.linear(
          const Offset(256, 128),
          const Offset(256, 384),
          <Color>[
            _sea.withValues(alpha: 0.0),
            _turquoise.withValues(alpha: 0.18),
          ],
        ),
    );
    canvas.drawCircle(const Offset(256, 300), 70, Paint()..color = _sun);
    final land = Path()
      ..moveTo(100, 300)
      ..cubicTo(170, 284, 210, 284, 256, 296)
      ..cubicTo(302, 308, 342, 308, 412, 290)
      ..lineTo(412, 420)
      ..lineTo(100, 420)
      ..close();
    canvas.drawPath(land, Paint()..color = _deep);
    final horizon = Path()
      ..moveTo(100, 300)
      ..cubicTo(170, 284, 210, 284, 256, 296)
      ..cubicTo(302, 308, 342, 308, 412, 290);
    canvas.drawPath(
      horizon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = _horizon,
    );
    canvas.drawPath(
      horizon.shift(const Offset(0, 42)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = _horizon.withValues(alpha: 0.45),
    );
    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40
        ..shader = Gradient.linear(
          ringRect.topLeft,
          ringRect.bottomRight,
          <Color>[_turquoise, _gold],
        ),
    );
    // A short sheen on the ring's upper left, like light on a dome.
    canvas.drawArc(
      ringRect,
      200 * math.pi / 180,
      0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = _highlight.withValues(alpha: 0.55),
    );
    canvas.restore();
  }

  static void paintBackground(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _box, _box),
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          const Offset(_box, _box),
          <Color>[_deep, _sea],
        ),
    );
  }
}
