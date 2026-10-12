import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/sky/sky_palette.dart';
import '../../core/theme/osmon_spacing.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../update/update_prompt.dart';
import 'osmon_nav_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab returns it to its first page.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) => UpdatePrompt(
    child: Scaffold(
      extendBody: true,
      body: navigationShell,
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
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
