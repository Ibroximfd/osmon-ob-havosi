import 'package:flutter/widgets.dart';

import '../widgets/home_view.dart';

/// The Weather Bloc is app-scoped (provided at the root), so the page adds
/// nothing but the view.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const HomeView();
}
