import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../domain/weather_grid.dart';
import '../bloc/map_bloc.dart';
import '../widgets/radar_view.dart';

class RadarPage extends StatelessWidget {
  const RadarPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<MapBloc>(
    create: (_) =>
        sl<MapBloc>(param1: MapLayer.precipitation)..add(const MapStarted()),
    child: const RadarView(),
  );
}
