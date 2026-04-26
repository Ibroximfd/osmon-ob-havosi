import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/pages/forecast/forecast_page.dart';
import '../../presentation/pages/map/map_page.dart';
import '../../presentation/pages/air_quality/air_quality_page.dart';
import '../../presentation/pages/alerts/alerts_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/agriculture/agriculture_page.dart';
import '../../presentation/pages/ai_photo/ai_photo_page.dart';
import '../../presentation/pages/chat/chat_page.dart';
import '../../presentation/pages/main_layout.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';

// Placeholder Pages
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Coming soon: $title')),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class AppRouter {
  static late GoRouter router;

  static void init(bool showOnboarding) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.search,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ChatPage(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) => const MapPage(),
            ),
            GoRoute(
              path: AppRoutes.aiPhoto,
              builder: (context, state) => const AIPhotoPage(),
            ),
            GoRoute(
              path: AppRoutes.forecast,
              builder: (context, state) => const ForecastPage(),
            ),
            GoRoute(
              path: AppRoutes.alerts,
              builder: (context, state) => const AlertsPage(),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: AppRoutes.airQuality,
              builder: (context, state) => const AirQualityPage(),
            ),
            GoRoute(
              path: AppRoutes.agriculture,
              builder: (context, state) => const AgriculturePage(),
            ),
          ],
        ),
      ],
    );
  }
}
