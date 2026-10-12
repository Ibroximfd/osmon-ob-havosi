import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'ads/ads_initializer.dart';
import 'ads/app_lifecycle_reactor.dart';
import 'app/background/background_refresh.dart';
import 'app/di/injector.dart';
import 'app/firebase/firebase_setup.dart';
import 'app/osmon_app.dart';
import 'app/services/push_messaging.dart';
import 'features/settings/domain/settings_repository.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Fire-and-forget: consent + SDK init + ad preloading must never delay
  // cold start or block the first frame.
  AdsInitializer.instance.initialize();
  AppLifecycleReactor.instance.start();

  // Before anything else that can fail, so start-up crashes are reported.
  await FirebaseSetup.initialize();

  tz_data.initializeTimeZones();
  await configureDependencies();
  // Registering background work talks to the platform; never block on it.
  BackgroundRefresh.register();
  if (FirebaseSetup.isReady) {
    // Topic subscriptions need the network; never block on them.
    sl<PushMessaging>().start(
      sl<SettingsRepository>().current.languageCode ?? 'uz',
    );
  }

  FlutterNativeSplash.remove();
  runApp(const OsmonApp());
}
