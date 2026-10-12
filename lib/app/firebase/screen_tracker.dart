import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

/// Logs a screen view whenever the router settles on a new location. Tab
/// switches in the stateful shell push no route, so a NavigatorObserver
/// alone would miss the most used screens.
final class ScreenTracker {
  ScreenTracker(this._router) {
    _router.routerDelegate.addListener(_onRouteChanged);
  }

  final GoRouter _router;
  String? _last;

  void _onRouteChanged() {
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    if (path.isEmpty || path == _last) return;
    _last = path;
    FirebaseAnalytics.instance.logScreenView(screenName: path);
  }

  void dispose() => _router.routerDelegate.removeListener(_onRouteChanged);
}
