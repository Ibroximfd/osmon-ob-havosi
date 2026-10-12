import 'package:flutter/widgets.dart';

import '../widgets/settings_view.dart';

/// The Settings Bloc is app-scoped, so the page adds nothing but the view.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const SettingsView();
}
