import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/field_bloc.dart';
import '../widgets/field_view.dart';

class FieldPage extends StatelessWidget {
  const FieldPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<FieldBloc>(
    create: (_) => sl<FieldBloc>()..add(const FieldRequested()),
    child: const FieldView(),
  );
}
