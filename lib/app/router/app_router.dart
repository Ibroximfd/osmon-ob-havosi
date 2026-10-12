import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/pages/chat_page.dart';
import '../../features/ai/presentation/pages/photo_page.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/field/presentation/pages/field_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/location/presentation/pages/search_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/map/presentation/pages/radar_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/prayer/presentation/pages/prayer_page.dart';
import '../../features/route/presentation/pages/route_page.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/weather/presentation/pages/home_page.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';

/// Five tabs in a stateful shell (each keeps its scroll and map position)
/// and full-screen feature pages pushed above it. Onboarding is enforced by
/// the redirect, never by individual screens.
GoRouter createRouter(SettingsRepository settings) {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: _StreamListenable(settings.watch()),
    redirect: (context, state) {
      final onboarded = settings.current.onboardingDone;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboarded && !atOnboarding) return AppRoutes.onboarding;
      if (onboarded && atOnboarding) return AppRoutes.home;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          _branch(AppRoutes.home, const HomePage()),
          _branch(AppRoutes.radar, const RadarPage()),
          _branch(AppRoutes.map, const MapPage()),
          _branch(AppRoutes.health, const HealthPage()),
          _branch(AppRoutes.settings, const SettingsPage()),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.search,
        builder: (context, state) =>
            SearchPage(pickOnly: state.uri.queryParameters['pick'] == '1'),
      ),
      _pushed(rootKey, AppRoutes.prayer, const PrayerPage()),
      _pushed(rootKey, AppRoutes.field, const FieldPage()),
      _pushed(rootKey, AppRoutes.route, const RoutePage()),
      _pushed(rootKey, AppRoutes.alerts, const AlertsPage()),
      _pushed(rootKey, AppRoutes.chat, const ChatPage()),
      _pushed(rootKey, AppRoutes.photo, const PhotoPage()),
    ],
  );
}

StatefulShellBranch _branch(String path, Widget page) => StatefulShellBranch(
  routes: <RouteBase>[GoRoute(path: path, builder: (context, state) => page)],
);

GoRoute _pushed(GlobalKey<NavigatorState> root, String path, Widget page) =>
    GoRoute(
      parentNavigatorKey: root,
      path: path,
      builder: (context, state) => page,
    );

/// Re-runs the redirect whenever settings change (onboarding completion).
final class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
