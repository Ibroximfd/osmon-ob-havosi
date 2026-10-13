import 'package:go_router/go_router.dart';

import '../../ads/interstitial_ad_manager.dart';
import 'app_routes.dart';

/// Opening a feature page from home is a natural break, so it counts as an
/// interstitial transition (the manager's caps decide whether one shows).
/// Tab switches are not counted: they are quick glances, not a new task.
final class AdTransitionTrigger {
  AdTransitionTrigger(this._router) {
    _router.routerDelegate.addListener(_onRouteChanged);
  }

  final GoRouter _router;
  String? _last;

  static const Set<String> _featurePages = <String>{
    AppRoutes.prayer,
    AppRoutes.field,
    AppRoutes.route,
    AppRoutes.alerts,
    AppRoutes.chat,
    AppRoutes.photo,
  };

  void _onRouteChanged() {
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    if (path == _last) return;
    _last = path;
    if (_featurePages.contains(path)) {
      InterstitialAdManager.instance.maybeShowOnTransition();
    }
  }

  void dispose() => _router.routerDelegate.removeListener(_onRouteChanged);
}
