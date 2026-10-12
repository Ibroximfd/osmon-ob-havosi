import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'ads/ads_initializer.dart';
import 'ads/app_lifecycle_reactor.dart';
import 'app/background/background_refresh.dart';
import 'app/di/injector.dart';
import 'app/osmon_app.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Fire-and-forget: consent + SDK init + ad preloading must never delay
  // cold start or block the first frame.
  AdsInitializer.instance.initialize();
  AppLifecycleReactor.instance.start();

  tz_data.initializeTimeZones();
  await configureDependencies();
  // Registering background work talks to the platform; never block on it.
  BackgroundRefresh.register();

  FlutterNativeSplash.remove();
  runApp(const OsmonApp());
}
