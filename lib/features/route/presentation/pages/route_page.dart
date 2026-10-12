import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/route_bloc.dart';
import '../widgets/route_view.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<RouteBloc>(
    create: (_) => sl<RouteBloc>(),
    child: const RouteView(),
  );
}
