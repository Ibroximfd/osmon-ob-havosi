// Renders the launcher icon, adaptive-icon layers and splash mark into
// assets/images/. Run on demand, then regenerate platform icons:
//   flutter test tool/brand/render_brand_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'osmon_mark.dart';

Future<void> _write(
  String path,
  int size,
  void Function(Canvas canvas, Size size) paint,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final extent = Size.square(size.toDouble());
  paint(canvas, extent);
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('render brand assets', () async {
    // Full icon for iOS and legacy Android.
    await _write(
      'assets/images/app_icon.png',
      1024,
      (c, s) => const OsmonMark().paint(c, s),
    );
    // Adaptive icon: the ring (66 % of the box) scaled into the 61 % safe circle.
    await _write(
      'assets/images/app_icon_foreground.png',
      1024,
      (c, s) => const OsmonMark(withBackground: false, scale: 0.86).paint(c, s),
    );
    await _write('assets/images/app_icon_background.png', 1024, (c, s) {
      c.scale(s.width / 512);
      OsmonMark.paintBackground(c);
    });
    // Android 12 splash: the icon must sit inside the central circle.
    await _write(
      'assets/images/splash_mark.png',
      1152,
      (c, s) => const OsmonMark(withBackground: false, scale: 0.9).paint(c, s),
    );
  });
}
