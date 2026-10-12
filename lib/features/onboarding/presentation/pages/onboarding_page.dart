import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_view.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<OnboardingBloc>(
    create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
    child: const OnboardingView(),
  );
}
