// Renders the Play Store screenshots (1080×1920) and feature graphic
// (1024×500) from the real screens, in Uzbek, Russian and English:
//   flutter test tool/store/render_store_shots_test.dart
// Output: store/play/<language>/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/app/locale/fallback_localizations.dart';
import 'package:osmon_uzbekiston_ob_havosi/app/shell/osmon_nav_bar.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_backdrop.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_palette.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_scene.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/app_theme.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/osmon_colors.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/osmon_typography.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/time/tz_time_zone_resolver.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/presentation/bloc/alerts_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/presentation/widgets/alerts_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/favorites/domain/favorites_repository.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/presentation/bloc/field_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/presentation/widgets/field_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/presentation/bloc/health_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/health/presentation/widgets/health_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/data/adhan_prayer_times_source.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/presentation/bloc/prayer_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/prayer/presentation/widgets/prayer_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/presentation/bloc/route_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/route/presentation/widgets/route_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/domain/app_settings.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/presentation/widgets/home_view.dart';
import 'package:osmon_uzbekiston_ob_havosi/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../test/helpers/fakes.dart';
import '../brand/osmon_mark.dart';
import 'seeded_blocs.dart';
import 'store_seeds.dart';

const Size _phone = Size(390, 844);
const Size _canvas = Size(360, 640);
const double _pixelRatio = 3;

const Map<String, List<(String, String)>> _copy =
    <String, List<(String, String)>>{
      'uz': <(String, String)>[
        ("14 daqiqadan keyin yomg'ir", 'Daqiqama-daqiqa aniq prognoz'),
        ('Namoz vaqtlari va quyosh yo\'li', 'Internetsiz ham aniq hisoblanadi'),
        ('Havo sifati va allergiya', 'AQI, gulchang taqvimi va bosim'),
        ("Yo'ldagi ob-havo", 'Har bir qism uchun alohida prognoz'),
        ('Dala rejimi', "Sovuq xavfi, sug'orish, purkash vaqti"),
        ('14 viloyat ogohlantirishlari', 'Xavfli ob-havodan oldindan xabar'),
      ],
      'ru': <(String, String)>[
        ('Дождь через 14 минут', 'Прогноз с точностью до минуты'),
        ('Время намаза и путь солнца', 'Точно даже без интернета'),
        ('Качество воздуха и аллергия', 'AQI, календарь пыльцы и давление'),
        ('Погода в дороге', 'Прогноз для каждого участка пути'),
        ('Режим «Поле»', 'Заморозки, полив, окна опрыскивания'),
        ('Предупреждения по 14 регионам', 'Узнайте об опасной погоде заранее'),
      ],
      'en': <(String, String)>[
        ('Rain in 14 minutes', 'Minute-by-minute precision'),
        (
          "Prayer times and the sun's path",
          'Calculated precisely, even offline',
        ),
        ('Air quality and allergies', 'AQI, pollen calendar and pressure'),
        ('Weather on your route', 'A forecast for every stretch of road'),
        ('Farm mode', 'Frost risk, irrigation, spray windows'),
        ('Alerts for 14 regions', 'Know about severe weather first'),
      ],
      'kk': <(String, String)>[
        ('14 минуттан кейін жаңбыр', 'Минутына дейін дәл болжам'),
        ('Намаз уақыты және күн жолы', 'Интернетсіз де дәл есептеледі'),
        ('Ауа сапасы және аллергия', 'AQI, тозаң күнтізбесі және қысым'),
        ('Жолдағы ауа райы', 'Жолдың әр бөлігіне жеке болжам'),
        ('Егістік режимі', 'Аяз қаупі, суару, бүрку уақыты'),
        ('14 өңір бойынша ескертулер', 'Қауіпті ауа райын алдын ала біліңіз'),
      ],
      'ky': <(String, String)>[
        ('14 мүнөттөн кийин жамгыр', 'Мүнөткө чейин так болжол'),
        ('Намаз убактысы жана күндүн жолу', 'Интернетсиз да так эсептелет'),
        ('Аба сапаты жана аллергия', 'AQI, чаңча календары жана басым'),
        ('Жолдогу аба ырайы', 'Жолдун ар бир бөлүгүнө өзүнчө болжол'),
        ('Талаа режими', 'Үшүк коркунучу, сугаруу, чачуу убактысы'),
        ('14 аймак боюнча эскертүүлөр', 'Кооптуу аба ырайын алдын ала билиңиз'),
      ],
    };

const Map<String, String> _tagline = <String, String>{
  'uz': "Ekranda tirik osmon, cho'ntakda foydali javoblar",
  'ru': 'Живое небо на экране, полезные ответы в кармане',
  'en': 'A living sky on screen, useful answers in your pocket',
  'kk': 'Экранда тірі аспан, қалтаңызда пайдалы жауаптар',
  'ky': 'Экранда тирүү асман, чөнтөгүңүздө пайдалуу жооптор',
};

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(
      Future<ByteData>.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  await loader.load();
}

final class _NoFavorites implements FavoritesRepository {
  @override
  List<Place> get all => const <Place>[];

  @override
  Future<void> toggle(Place place) async {}

  @override
  Stream<List<Place>> watch() => const Stream<List<Place>>.empty();
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await _loadFont('Geologica', 'assets/fonts/Geologica.ttf');
    await _loadFont('Onest', 'assets/fonts/Onest.ttf');
    await _loadFont(
      'packages/lucide_icons/Lucide',
      'packages/lucide_icons/assets/lucide.ttf',
    );
  });

  for (final language in _copy.keys) {
    testWidgets('store screenshots · $language', (tester) async {
      final seeds = StoreSeeds(language);
      final outDir = Directory('store/play/$language')
        ..createSync(recursive: true);
      tester.view.physicalSize = _canvas * _pixelRatio;
      tester.view.devicePixelRatio = _pixelRatio;
      addTearDown(tester.view.reset);

      final weather = SeededWeatherBloc(seeds.home());
      final screens = <(String, SkyScene, SkyScene, int, Widget)>[
        ('01_nowcast', SkyScene.rain, SkyScene.rain, 0, const HomeView()),
        (
          '02_prayer',
          SkyScene.twilight,
          SkyScene.twilight,
          -1,
          BlocProvider<PrayerBloc>(
            create: (_) => PrayerBloc(
              location: FakeLocationRepository(selected: seeds.tashkent),
              settings: FakeSettingsRepository(),
              times: const AdhanPrayerTimesSource(),
              timeZones: const TzTimeZoneResolver(),
              clock: () => DateTime.utc(2026, 10, 12, 9, 6),
              tick: const Duration(days: 1),
            )..add(const PrayerStarted()),
            child: const PrayerView(),
          ),
        ),
        (
          '03_health',
          SkyScene.dust,
          SkyScene.clearDay,
          3,
          BlocProvider<HealthBloc>(
            create: (_) => SeededHealthBloc(seeds.health()),
            child: const HealthView(),
          ),
        ),
        (
          '04_route',
          SkyScene.fog,
          SkyScene.fog,
          -1,
          BlocProvider<RouteBloc>(
            create: (_) => SeededRouteBloc(seeds.route()),
            child: const RouteView(),
          ),
        ),
        (
          '05_field',
          SkyScene.snow,
          SkyScene.snow,
          -1,
          BlocProvider<FieldBloc>(
            create: (_) => SeededFieldBloc(seeds.field()),
            child: const FieldView(),
          ),
        ),
        (
          '06_alerts',
          SkyScene.storm,
          SkyScene.storm,
          -1,
          BlocProvider<AlertsBloc>(
            create: (_) => SeededAlertsBloc(seeds.alerts()),
            child: const AlertsView(),
          ),
        ),
      ];

      for (var i = 0; i < screens.length; i++) {
        final (file, frameScene, phoneScene, tab, screen) = screens[i];
        final (headline, subline) = _copy[language]![i];
        final key = GlobalKey();
        await tester.pumpWidget(
          _App(
            language: language,
            weather: weather,
            child: RepaintBoundary(
              key: key,
              child: _StoreFrame(
                headline: headline,
                subline: subline,
                scene: frameScene,
                phone: _PhoneScreen(scene: phoneScene, tab: tab, child: screen),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(milliseconds: 100));
        await _capture(tester, key, '${outDir.path}/$file.png');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.runAsync(weather.close);
    });

    testWidgets('feature graphic · $language', (tester) async {
      const size = Size(1024, 500);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: _FeatureGraphic(tagline: _tagline[language]!),
          ),
        ),
      );
      await tester.pump();
      await _capture(
        tester,
        key,
        'store/play/$language/feature_graphic.png',
        pixelRatio: 1,
      );
    });
  }
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey key,
  String path, {
  double pixelRatio = _pixelRatio,
}) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File(path).writeAsBytesSync(bytes!);
}

class _App extends StatelessWidget {
  const _App({
    required this.language,
    required this.weather,
    required this.child,
  });

  final String language;
  final WeatherBloc weather;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<WeatherBloc>.value(value: weather),
      BlocProvider<SettingsBloc>(
        create: (_) => SettingsBloc(
          FakeSettingsRepository(AppSettings(languageCode: language)),
          const FakePermissions(granted: true),
        ),
      ),
      BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc(_NoFavorites())),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

/// The phone's own screen: the live sky, the page, and (for tab pages) the
/// floating nav bar, at a real phone's logical size.
class _PhoneScreen extends StatelessWidget {
  const _PhoneScreen({
    required this.scene,
    required this.tab,
    required this.child,
  });

  final SkyScene scene;

  /// Highlighted tab, or -1 for pushed pages without the tab bar.
  final int tab;
  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      size: _phone,
      padding: const EdgeInsets.only(top: 44, bottom: 20),
      viewPadding: const EdgeInsets.only(top: 44, bottom: 20),
      // Entrance animations would be caught mid-fade in a still image.
      disableAnimations: true,
    ),
    child: SizedBox.fromSize(
      size: _phone,
      child: SkyBackdrop(
        scene: scene,
        animate: false,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: child),
            if (tab >= 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 28,
                child: OsmonNavBar(
                  currentIndex: tab,
                  onSelected: (_) {},
                  tint: scene.palette.tint,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({
    required this.headline,
    required this.subline,
    required this.scene,
    required this.phone,
  });

  final String headline;
  final String subline;
  final SkyScene scene;
  final Widget phone;

  static const double _phoneWidth = 252;
  static const double _bezel = 7;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: SizedBox.fromSize(
      size: _canvas,
      child: SkyBackdrop(
        scene: scene,
        animate: false,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                headline,
                textAlign: TextAlign.center,
                style: OsmonType.titleLarge.copyWith(
                  fontSize: 27,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subline,
              textAlign: TextAlign.center,
              style: OsmonType.body.copyWith(color: OsmonColors.textSecondary),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Container(
                  width: _phoneWidth,
                  padding: const EdgeInsets.all(_bezel),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
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
                        color: Color(0x80000000),
                        blurRadius: 40,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: AspectRatio(
                      aspectRatio: _phone.width / _phone.height,
                      child: FittedBox(child: phone),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: SizedBox(
      width: 1024,
      height: 500,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1024, 500)),
        child: SkyBackdrop(
          scene: SkyScene.twilight,
          animate: false,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 90),
              SizedBox.square(
                dimension: 210,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: CustomPaint(painter: _MarkPainter()),
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'OSMON',
                      style: OsmonType.hero.copyWith(
                        fontSize: 96,
                        letterSpacing: 6,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tagline,
                      style: OsmonType.titleMedium.copyWith(
                        fontSize: 26,
                        color: OsmonColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
    ),
  );
}

final class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => const OsmonMark().paint(canvas, size);

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}
