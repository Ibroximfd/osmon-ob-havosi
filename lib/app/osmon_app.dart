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
import 'locale/fallback_localizations.dart';
import 'router/app_router.dart';
import 'side_effects.dart';

class OsmonApp extends StatefulWidget {
  const OsmonApp({super.key});

  @override
  State<OsmonApp> createState() => _OsmonAppState();
}

class _OsmonAppState extends State<OsmonApp> {
  late final GoRouter _router = createRouter(sl<SettingsRepository>());

  @override
  void dispose() {
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
        builder: (context, child) =>
            AppSideEffects(child: _Sky(child: child ?? const SizedBox())),
      ),
    ),
  );
}

/// One live sky behind the whole router, following the current forecast
/// and the user's motion settings.
class _Sky extends StatelessWidget {
  const _Sky({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scene = context.select<WeatherBloc, SkyScene>(
      (bloc) => bloc.state.scene,
    );
    final settings = context.select<SettingsBloc, AppSettings>(
      (bloc) => bloc.state.settings,
    );
    return SkyBackdrop(
      scene: scene,
      animate: settings.animatesSky,
      batterySaver: settings.batterySaver,
      child: child,
    );
  }
}
