// Renders the frames of the promo video: 16 s at 30 fps, square (1080×1080,
// Telegram feed), vertical (1080×1920, stories) and landscape (1920×1080,
// YouTube), Uzbek and Russian. Uses the bare phone screens the store
// renderer saves, so run:
//
//   flutter test tool/store/render_store_shots_test.dart
//   flutter test tool/promo/render_promo_test.dart
//   python3 tool/promo/make_music.py build/promo/music.wav
//   sh tool/promo/encode.sh
//
// Output: build/promo/frames/<language>_<format>/f0000.png …

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_backdrop.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_scene.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/app_theme.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/osmon_colors.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/osmon_typography.dart';

import '../brand/osmon_mark.dart';

const int _fps = 30;
const double _seconds = 16;
const double _pixelRatio = 3;
const Size _phone = Size(390, 844);

/// When the phone leaves and the logo card takes over.
const double _endStart = 13.2;

/// Each format's layout, in logical pixels (rendered at 3×).
enum _Format {
  /// Telegram feed: headline on top, phone below.
  square(
    Size(360, 360),
    headline: Rect.fromLTWH(20, 50, 320, 0),
    push: Rect.fromLTWH(20, 168, 320, 0),
    phoneWidth: 196,
    phoneTop: 136,
    phoneCenterX: 180,
    logo: 92,
    logoCenterY: 112,
  ),

  /// Stories: the same, taller.
  vertical(
    Size(360, 640),
    headline: Rect.fromLTWH(20, 50, 320, 0),
    push: Rect.fromLTWH(20, 300, 320, 0),
    phoneWidth: 236,
    phoneTop: 196,
    phoneCenterX: 180,
    logo: 116,
    logoCenterY: 218,
  ),

  /// YouTube 16:9: headline on the left, phone on the right.
  landscape(
    Size(640, 360),
    headline: Rect.fromLTWH(44, 124, 292, 0),
    headlineAlign: TextAlign.start,
    headlineSize: 33,
    push: Rect.fromLTWH(336, 132, 276, 0),
    phoneWidth: 216,
    phoneTop: 46,
    phoneCenterX: 474,
    logo: 92,
    logoCenterY: 104,
  );

  const _Format(
    this.canvas, {
    required this.headline,
    required this.push,
    required this.phoneWidth,
    required this.phoneTop,
    required this.phoneCenterX,
    required this.logo,
    required this.logoCenterY,
    this.headlineAlign = TextAlign.center,
    this.headlineSize = 27,
  });

  final Size canvas;

  /// Left, top and width of the headline block (height is the text's).
  final Rect headline;
  final TextAlign headlineAlign;
  final double headlineSize;

  /// Left, resting top and width of the opening notification.
  final Rect push;
  final double phoneWidth;
  final double phoneTop;
  final double phoneCenterX;
  final double logo;
  final double logoCenterY;
}

/// One beat of the story: its sky, its headline, and the phone screen.
final class _Beat {
  const _Beat(this.start, this.scene, this.headline, {this.screen});

  final double start;
  final SkyScene scene;
  final String headline;

  /// File name in `build/promo/screens/<language>/`, without extension.
  final String? screen;
}

/// The push notification that drops in during the opening beat.
final class _Push {
  const _Push({required this.time, required this.title, required this.body});

  final String time;
  final String title;
  final String body;
}

final class _Copy {
  const _Copy({
    required this.beats,
    required this.push,
    required this.tagline,
    required this.cta,
    required this.languages,
  });

  final List<_Beat> beats;
  final _Push push;
  final String tagline;
  final String cta;
  final String languages;
}

const String _languageList =
    "O'zbek · Русский · English · Қазақ · Кыргыз · Тоҷикӣ";

const Map<String, _Copy> _copy = <String, _Copy>{
  'uz': _Copy(
    beats: <_Beat>[
      _Beat(0, SkyScene.rain, "Yomg'irdan oldin\nxabar beramiz"),
      _Beat(
        3,
        SkyScene.rain,
        'Daqiqama-daqiqa\naniq prognoz',
        screen: '01_nowcast',
      ),
      _Beat(
        5.8,
        SkyScene.twilight,
        "Namoz vaqtlari\nva quyosh yo'li",
        screen: '02_prayer',
      ),
      _Beat(
        8.4,
        SkyScene.fog,
        "Yo'lda ob-havo\nqanday bo'ladi?",
        screen: '04_route',
      ),
      _Beat(
        11,
        SkyScene.storm,
        'Xavfli ob-havodan\noldindan xabar',
        screen: '06_alerts',
      ),
    ],
    push: _Push(
      time: 'hozir',
      title: "Yomg'ir 14 daqiqadan keyin",
      body: 'Soyabonni olib chiqing — 1,5 soat davom etadi.',
    ),
    tagline: "O'zbekiston ob-havosi",
    cta: "Google Play'da bepul",
    languages: _languageList,
  ),
  'ru': _Copy(
    beats: <_Beat>[
      _Beat(0, SkyScene.rain, 'Предупредим\nдо дождя'),
      _Beat(
        3,
        SkyScene.rain,
        'Точный прогноз\nпо минутам',
        screen: '01_nowcast',
      ),
      _Beat(
        5.8,
        SkyScene.twilight,
        'Время намаза\nи путь солнца',
        screen: '02_prayer',
      ),
      _Beat(
        8.4,
        SkyScene.fog,
        'Какая погода\nбудет в дороге?',
        screen: '04_route',
      ),
      _Beat(
        11,
        SkyScene.storm,
        'Предупреждения\nоб опасной погоде',
        screen: '06_alerts',
      ),
    ],
    push: _Push(
      time: 'сейчас',
      title: 'Дождь через 14 минут',
      body: 'Возьмите зонт — продлится 1,5 часа.',
    ),
    tagline: 'Погода Узбекистана',
    cta: 'Бесплатно в Google Play',
    languages: _languageList,
  ),
};

double _clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

/// 0→1 over [duration] seconds starting at [from].
double _progress(double t, double from, double duration) =>
    _clamp01((t - from) / duration);

double _easeOut(double v) => Curves.easeOutCubic.transform(_clamp01(v));
double _easeIn(double v) => Curves.easeInCubic.transform(_clamp01(v));

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('Geologica', 'assets/fonts/Geologica.ttf');
    await _loadFont('Onest', 'assets/fonts/Onest.ttf');
  });

  for (final language in _copy.keys) {
    for (final format in _Format.values) {
      testWidgets(
        'promo · ${language}_${format.name}',
        (tester) async {
          final copy = _copy[language]!;
          tester.view.physicalSize = format.canvas * _pixelRatio;
          tester.view.devicePixelRatio = _pixelRatio;
          addTearDown(tester.view.reset);

          final screens = <String, ui.Image>{};
          for (final beat in copy.beats) {
            final name = beat.screen;
            if (name == null) continue;
            final file = File('build/promo/screens/$language/$name.png');
            expect(
              file.existsSync(),
              isTrue,
              reason: 'Run tool/store/render_store_shots_test.dart first',
            );
            screens[name] = (await tester.runAsync(
              () => decodeImageFromList(file.readAsBytesSync()),
            ))!;
          }

          final outDir = Directory(
            'build/promo/frames/${language}_${format.name}',
          );
          if (outDir.existsSync()) outDir.deleteSync(recursive: true);
          outDir.createSync(recursive: true);

          final key = GlobalKey();
          const frame = Duration(microseconds: 1000000 ~/ _fps);
          final frames = (_seconds * _fps).round();
          for (var i = 0; i < frames; i++) {
            await tester.pumpWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark,
                home: Material(
                  type: MaterialType.transparency,
                  child: RepaintBoundary(
                    key: key,
                    child: _PromoFrame(
                      t: i / _fps,
                      copy: copy,
                      format: format,
                      screens: screens,
                    ),
                  ),
                ),
              ),
            );
            // Advances the live sky's ticker by one video frame.
            await tester.pump(frame);
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final bytes = await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: _pixelRatio);
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              return data!.buffer.asUint8List();
            });
            File(
              '${outDir.path}/f${i.toString().padLeft(4, '0')}.png',
            ).writeAsBytesSync(bytes!);
          }
        },
        timeout: const Timeout(Duration(minutes: 30)),
      );
    }
  }
}

class _PromoFrame extends StatelessWidget {
  const _PromoFrame({
    required this.t,
    required this.copy,
    required this.format,
    required this.screens,
  });

  final double t;
  final _Copy copy;
  final _Format format;
  final Map<String, ui.Image> screens;

  int get _beatIndex {
    var index = 0;
    for (var i = 0; i < copy.beats.length; i++) {
      if (copy.beats[i].start <= t) index = i;
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final ending = t >= _endStart;
    final scene = ending ? SkyScene.clearNight : copy.beats[_beatIndex].scene;
    return SizedBox.fromSize(
      size: format.canvas,
      child: SkyBackdrop(
        scene: scene,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            _Phone(t: t, copy: copy, format: format, screens: screens),
            _PushBanner(t: t, copy: copy, format: format),
            _Headlines(t: t, copy: copy, format: format),
            _Brand(t: t),
            if (ending) _EndCard(t: t - _endStart, copy: copy, format: format),
          ],
        ),
      ),
    );
  }
}

/// Small mark + wordmark in the corner, so every beat carries the brand.
class _Brand extends StatelessWidget {
  const _Brand({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final opacity =
        _easeOut(_progress(t, 0.1, 0.5)) *
        (1 - _progress(t, _endStart - 0.3, 0.3));
    return Positioned(
      left: 18,
      top: 18,
      child: Opacity(
        opacity: opacity,
        child: Row(
          children: <Widget>[
            const SizedBox.square(
              dimension: 20,
              child: CustomPaint(painter: _MarkPainter()),
            ),
            const SizedBox(width: 7),
            Text(
              'OSMON',
              style: OsmonType.captionStrong.copyWith(
                fontFamily: 'Geologica',
                letterSpacing: 3,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The opening hook: Osmon's own rain notification drops in, buzzes like a
/// phone on vibrate, and leaves with the first headline.
class _PushBanner extends StatelessWidget {
  const _PushBanner({
    required this.t,
    required this.copy,
    required this.format,
  });

  final double t;
  final _Copy copy;
  final _Format format;

  static const double _in = 0.55;

  @override
  Widget build(BuildContext context) {
    final end = copy.beats[1].start;
    if (t < _in || t > end) return const SizedBox.shrink();
    final drop = Curves.easeOutBack.transform(_progress(t, _in, 0.55));
    final leave = _easeIn(_progress(t, end - 0.3, 0.3));
    // Two short buzzes once it has landed, like the real vibration.
    final buzz = _progress(t, _in + 0.55, 0.45);
    final shake = buzz > 0 && buzz < 1 ? math.sin(buzz * math.pi * 8) * 3 : 0.0;
    final slot = format.push;
    final push = copy.push;
    return Positioned(
      left: slot.left + shake,
      width: slot.width,
      top: slot.top - (1 - drop) * 70 - leave * 16,
      child: Opacity(
        opacity: _clamp01(drop * 1.4) * (1 - leave),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OsmonColors.inkSheet,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: OsmonColors.glassStroke),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x73000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: const SizedBox.square(
                  dimension: 38,
                  child: CustomPaint(painter: _MarkPainter()),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'OSMON',
                          style: OsmonType.captionStrong.copyWith(
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          push.time,
                          style: OsmonType.caption.copyWith(
                            color: OsmonColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(push.title, style: OsmonType.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      push.body,
                      style: OsmonType.caption.copyWith(
                        color: OsmonColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each beat's headline slides up into place and drifts out before the
/// next one arrives.
class _Headlines extends StatelessWidget {
  const _Headlines({required this.t, required this.copy, required this.format});

  final double t;
  final _Copy copy;
  final _Format format;

  @override
  Widget build(BuildContext context) {
    final beats = copy.beats;
    final children = <Widget>[];
    for (var i = 0; i < beats.length; i++) {
      final beat = beats[i];
      final end = i + 1 < beats.length ? beats[i + 1].start : _endStart;
      if (t < beat.start || t > end) continue;
      final enter = _easeOut(_progress(t, beat.start + 0.12, 0.5));
      final leave = _easeIn(_progress(t, end - 0.28, 0.28));
      final opacity = enter * (1 - leave);
      final dy = (1 - enter) * 16 - leave * 10;
      children.add(
        Positioned(
          left: format.headline.left,
          width: format.headline.width,
          top: format.headline.top + dy,
          child: Opacity(
            opacity: opacity,
            child: Text(
              beat.headline,
              textAlign: format.headlineAlign,
              style: OsmonType.titleLarge.copyWith(
                fontSize: format.headlineSize,
                height: 1.12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    return Stack(children: children);
  }
}

/// The phone rises in with the first screen, cross-fades between screens
/// on each beat, floats gently, and slides away for the logo card.
class _Phone extends StatelessWidget {
  const _Phone({
    required this.t,
    required this.copy,
    required this.format,
    required this.screens,
  });

  final double t;
  final _Copy copy;
  final _Format format;
  final Map<String, ui.Image> screens;

  static const double _bezel = 6;
  static const double _fade = 0.35;

  @override
  Widget build(BuildContext context) {
    final withScreens = copy.beats.where((b) => b.screen != null).toList();
    final first = withScreens.first.start;
    if (t < first) return const SizedBox.shrink();

    final rise = _easeOut(_progress(t, first, 0.8));
    final leave = _easeIn(_progress(t, _endStart - 0.1, 0.6));
    final float = math.sin(t * 1.7) * 2.5;
    final top =
        format.phoneTop +
        (1 - rise) * format.canvas.height * 0.9 +
        leave * format.canvas.height * 0.8 +
        float;

    // Current screen over the previous one while the beat cross-fades.
    final layers = <Widget>[];
    for (var i = 0; i < withScreens.length; i++) {
      final beat = withScreens[i];
      if (beat.start > t) break;
      final opacity = i == 0 ? 1.0 : _easeOut(_progress(t, beat.start, _fade));
      layers.add(
        Opacity(
          opacity: opacity,
          child: RawImage(
            image: screens[beat.screen],
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
    }

    final width = format.phoneWidth;
    return Positioned(
      left: format.phoneCenterX - width / 2,
      top: top,
      child: Opacity(
        opacity: 1 - leave,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(_bezel),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF39414F),
                Color(0xFF0D1420),
                Color(0xFF273243),
              ],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x8C000000),
                blurRadius: 36,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: AspectRatio(
              aspectRatio: _phone.width / _phone.height,
              child: Stack(fit: StackFit.expand, children: layers),
            ),
          ),
        ),
      ),
    );
  }
}

/// The closing card: the mark springs in over a soft glow, then the name,
/// the tagline, the call to action and the six languages.
class _EndCard extends StatelessWidget {
  const _EndCard({required this.t, required this.copy, required this.format});

  /// Seconds since the card started.
  final double t;
  final _Copy copy;
  final _Format format;

  @override
  Widget build(BuildContext context) {
    final logo = format.logo;
    final centerY = format.logoCenterY;
    final pop = Curves.elasticOut.transform(_progress(t, 0.15, 1.1));
    final logoOpacity = _easeOut(_progress(t, 0.15, 0.35));

    Widget appear(double from, Widget child) {
      final p = _easeOut(_progress(t, from, 0.55));
      return Opacity(
        opacity: p,
        child: Transform.translate(
          offset: Offset(0, (1 - p) * 12),
          child: child,
        ),
      );
    }

    return Positioned.fill(
      child: Column(
        children: <Widget>[
          SizedBox(height: centerY - logo / 2),
          Opacity(
            opacity: logoOpacity,
            child: SizedBox.square(
              dimension: logo,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.scale(
                    scale: 2.4,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            OsmonColors.goldSoft,
                            OsmonColors.accentSoft,
                            Color(0x00000000),
                          ],
                          stops: <double>[0, 0.45, 1],
                        ),
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.6 + 0.4 * pop,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(logo * 0.23),
                      child: const CustomPaint(
                        painter: _MarkPainter(),
                        child: SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          appear(
            0.45,
            Text(
              'OSMON',
              style: OsmonType.titleLarge.copyWith(
                fontSize: 34,
                letterSpacing: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 4),
          appear(
            0.65,
            Text(
              copy.tagline,
              style: OsmonType.body.copyWith(color: OsmonColors.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          appear(
            0.9,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: OsmonColors.accent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: OsmonColors.accentSoft,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                copy.cta,
                style: OsmonType.bodyStrong.copyWith(
                  color: OsmonColors.ink,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          appear(
            1.15,
            Text(
              copy.languages,
              style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

final class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) => const OsmonMark().paint(canvas, size);

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}
