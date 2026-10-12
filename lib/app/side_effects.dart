import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/bloc/load_status.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/weather/presentation/bloc/weather_bloc.dart';
import 'di/injector.dart';
import 'firebase/firebase_setup.dart';
import 'services/home_widget_sync.dart';
import 'services/notification_planner.dart';
import 'services/push_messaging.dart';

/// App-wide reactions that are not UI: every fresh forecast updates the
/// home widget and the notification plan; settings changes re-plan prayer
/// reminders and move the push topic; returning to the app re-checks
/// location access. Listeners, not Blocs, own these platform calls.
class AppSideEffects extends StatefulWidget {
  const AppSideEffects({super.key, required this.child});

  final Widget child;

  @override
  State<AppSideEffects> createState() => _AppSideEffectsState();
}

class _AppSideEffectsState extends State<AppSideEffects> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          context.read<WeatherBloc>().add(const WeatherAppResumed()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: <BlocListener<dynamic, dynamic>>[
      BlocListener<WeatherBloc, WeatherState>(
        listenWhen: (previous, current) =>
            current.forecast != null &&
            current.forecast != previous.forecast &&
            current.status == LoadStatus.ready,
        listener: (context, state) {
          final settings = context.read<SettingsBloc>().state.settings;
          final forecast = state.forecast!;
          sl<NotificationPlanner>().handleForecast(forecast, settings);
          sl<NotificationPlanner>().schedulePrayers(forecast.place, settings);
          sl<HomeWidgetSync>().publish(forecast, settings);
        },
      ),
      BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            previous.settings.prayerMethod != current.settings.prayerMethod ||
            previous.settings.isEnabled(NotificationKind.prayer) !=
                current.settings.isEnabled(NotificationKind.prayer) ||
            previous.settings.languageCode != current.settings.languageCode,
        listener: (context, state) {
          final place = context.read<WeatherBloc>().state.place;
          if (place != null) {
            sl<NotificationPlanner>().schedulePrayers(place, state.settings);
          }
        },
      ),
      BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            FirebaseSetup.isReady &&
            previous.settings.languageCode != current.settings.languageCode,
        listener: (context, state) => sl<PushMessaging>().syncLanguage(
          state.settings.languageCode ?? 'uz',
        ),
      ),
    ],
    child: widget.child,
  );
}
