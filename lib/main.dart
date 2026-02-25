import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_open_ad_manager.dart';
import 'core/utils/app_lifecycle_reactor.dart';

import 'presentation/blocs/home_bloc/home_bloc.dart';
import 'presentation/blocs/settings_cubit/settings_cubit.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  MobileAds.instance.initialize();

  // Load App Open Ad
  AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
  AppLifecycleReactor appLifecycleReactor = AppLifecycleReactor(
    appOpenAdManager: appOpenAdManager,
  );
  WidgetsBinding.instance.addObserver(appLifecycleReactor);

  await di.init();

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
