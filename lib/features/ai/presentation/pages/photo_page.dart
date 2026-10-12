import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/photo_bloc.dart';
import '../widgets/photo_view.dart';

class PhotoPage extends StatelessWidget {
  const PhotoPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<PhotoBloc>(
    create: (_) => sl<PhotoBloc>(),
    child: const PhotoView(),
  );
}
