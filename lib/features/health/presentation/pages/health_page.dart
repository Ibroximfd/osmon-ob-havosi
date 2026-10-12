import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/health_bloc.dart';
import '../widgets/health_view.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<HealthBloc>(
    create: (_) => sl<HealthBloc>()..add(const HealthRequested()),
    child: const HealthView(),
  );
}
