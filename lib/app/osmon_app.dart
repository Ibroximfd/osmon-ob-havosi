import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/sky/sky_backdrop.dart';
import '../core/sky/sky_scene.dart';
import '../core/theme/app_theme.dart';
import '../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/weather/presentation/bloc/weather_bloc.dart';
import 'di/injector.dart';
import 'firebase/firebase_setup.dart';
import 'firebase/screen_tracker.dart';
import 'locale/fallback_localizations.dart';
import 'router/ad_transition_trigger.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'side_effects.dart';

class OsmonApp extends StatefulWidget {
  const OsmonApp({super.key});

  @override
  State<OsmonApp> createState() => _OsmonAppState();
}

class _OsmonAppState extends State<OsmonApp> {
  late final GoRouter _router = createRouter(sl<SettingsRepository>());
  ScreenTracker? _screens;
  late final AdTransitionTrigger _adTransitions;

  @override
  void initState() {
    super.initState();
    if (FirebaseSetup.isReady) _screens = ScreenTracker(_router);
    _adTransitions = AdTransitionTrigger(_router);
  }

  @override
  void dispose() {
    _adTransitions.dispose();
    _screens?.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<SettingsBloc>.value(value: sl<SettingsBloc>()),
      BlocProvider<WeatherBloc>.value(
        value: sl<WeatherBloc>()..add(const WeatherStarted()),
      ),
      BlocProvider<FavoritesBloc>.value(value: sl<FavoritesBloc>()),
    ],
    child: BlocSelector<SettingsBloc, SettingsState, String>(
      selector: (state) => state.settings.languageCode ?? 'uz',
      builder: (context, language) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appName,
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
        routerConfig: _router,
        builder: (context, child) => AppSideEffects(
          child: _Sky(router: _router, child: child ?? const SizedBox()),
        ),
      ),
    ),
  );
}

/// One live sky behind the whole router, following the current forecast
/// and the user's motion settings.
class _Sky extends StatelessWidget {
  const _Sky({required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  /// The full-screen map covers the sky completely; animating it there only
  /// takes frames away from the map.
  bool get _hidden =>
      router.routerDelegate.currentConfiguration.uri.path == AppRoutes.map;

  @override
  Widget build(BuildContext context) {
    final scene = context.select<WeatherBloc, SkyScene>(
      (bloc) => bloc.state.scene,
    );
    final settings = context.select<SettingsBloc, AppSettings>(
      (bloc) => bloc.state.settings,
    );
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, child) => SkyBackdrop(
        scene: scene,
        animate: settings.animatesSky && !_hidden,
        batterySaver: settings.batterySaver,
        child: child!,
      ),
      child: child,
    );
  }
}
