import 'package:flutter/material.dart';

import 'app_open_ad_manager.dart';

/// Shows the App Open ad only when the app returns from background to
/// foreground — never on cold start (there is no "previous" resumed event
/// on first launch, so this observer simply never fires then).
class AppLifecycleReactor extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppOpenAdManager.instance.showAdIfAvailable();
    }
  }
}
