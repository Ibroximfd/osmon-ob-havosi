import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/prayer_bloc.dart';
import '../widgets/prayer_view.dart';

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<PrayerBloc>(
    create: (_) => sl<PrayerBloc>()..add(const PrayerStarted()),
    child: const PrayerView(),
  );
}
