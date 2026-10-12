import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../domain/weather_grid.dart';
import '../bloc/map_bloc.dart';
import '../widgets/map_view.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<MapBloc>(
    create: (_) =>
        sl<MapBloc>(param1: MapLayer.temperature)..add(const MapStarted()),
    child: const MapView(),
  );
}
