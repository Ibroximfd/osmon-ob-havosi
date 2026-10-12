import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/alerts_bloc.dart';
import '../widgets/alerts_view.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<AlertsBloc>(
    create: (_) => sl<AlertsBloc>()..add(const AlertsRequested()),
    child: const AlertsView(),
  );
}
