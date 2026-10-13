import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/sky/sky_palette.dart';
import '../../core/theme/osmon_spacing.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/widgets/notification_denied_listener.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../router/app_routes.dart';
import '../update/update_prompt.dart';
import 'osmon_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void initState() {
    super.initState();
    // After the first frame, so the system dialog opens over the app and
    // not over a blank window.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsBloc>().add(const SettingsMainScreenShown());
      }
    });
  }

  void _select(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab returns it to its first page.
    initialLocation: index == navigationShell.currentIndex,
  );

  bool get _onMap =>
      navigationShell
          .route
          .branches[navigationShell.currentIndex]
          .defaultRoute
          ?.path ==
      AppRoutes.map;

  @override
  Widget build(BuildContext context) => UpdatePrompt(
    child: Scaffold(
      extendBody: true,
      // One listener for every tab: the tabs stay mounted side by side, so
      // a listener per tab would stack the same snackbar several times.
      body: NotificationDeniedListener(child: navigationShell),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OsmonSpace.gutter,
                0,
                OsmonSpace.gutter,
                OsmonSpace.s8,
              ),
              child: BlocSelector<WeatherBloc, WeatherState, Color>(
                selector: (state) => state.scene.palette.tint,
                builder: (context, tint) => OsmonNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onSelected: _select,
                  tint: tint,
                  overMap: _onMap,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
