import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads/ads_initializer.dart';
import 'ads/app_lifecycle_reactor.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

import 'presentation/blocs/favorites_cubit/favorites_cubit.dart';
import 'presentation/blocs/home_bloc/home_bloc.dart';
import 'presentation/blocs/settings_cubit/settings_cubit.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Fire-and-forget: consent + SDK init + ad preloading must never delay
  // cold start or block the first frame.
  AdsInitializer.instance.initialize();
  WidgetsBinding.instance.addObserver(AppLifecycleReactor());

  await di.init();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('show_onboarding') ?? true;
  final savedTheme = await AdaptiveTheme.getThemeMode();

  AppRouter.init(showOnboarding);
  FlutterNativeSplash.remove();

  runApp(OsmonApp(savedThemeMode: savedTheme));
}

class OsmonApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const OsmonApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsCubit>()),
        BlocProvider(create: (_) => di.sl<FavoritesCubit>()),
      ],
      child: AdaptiveTheme(
        light: AppTheme.lightTheme,
        dark: AppTheme.darkTheme,
        initial: savedThemeMode ?? AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp.router(
          title: 'Osmon',
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
