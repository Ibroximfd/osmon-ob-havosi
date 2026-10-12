import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_open_ad_manager.dart';

/// Shows the App Open ad when the whole app returns to the foreground.
/// Uses the SDK's process-level notifier (Google's guidance) rather than a
/// WidgetsBindingObserver, which also fires for permission dialogs and for
/// our own full-screen ads.
class AppLifecycleReactor {
  AppLifecycleReactor._();
  static final AppLifecycleReactor instance = AppLifecycleReactor._();

  StreamSubscription<AppState>? _subscription;

  Future<void> start() async {
    if (_subscription != null) return;
    await AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.foreground) {
        AppOpenAdManager.instance.showAdIfAvailable();
      }
    });
  }
}
