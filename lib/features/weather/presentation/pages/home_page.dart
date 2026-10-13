import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../widgets/home_view.dart';

/// The Weather Bloc is app-scoped (provided at the root); the page adds the
/// prayer clock behind the "next prayer" tile.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<PrayerBloc>(
    create: (_) => sl<PrayerBloc>()..add(const PrayerStarted()),
    child: const HomeView(),
  );
}
