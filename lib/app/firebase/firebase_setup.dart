import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Crash reports, analytics and push. Firebase is optional at runtime: if it
/// cannot start, the app runs as before, only without telemetry.
abstract final class FirebaseSetup {
  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on Exception catch (error) {
      debugPrint('FirebaseSetup: disabled ($error)');
      return;
    }
    _ready = true;

    // Debug sessions are the developer's own; keep the dashboards about users.
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
