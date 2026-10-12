import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/units.dart';
import '../../../core/format/formats.dart';
import '../../../core/l10n/l10n.dart';
import 'bloc/settings_bloc.dart';

/// Formats for the current language and units. Rebuilds the caller only
/// when one of the three units changes.
Formats formatsOf(BuildContext context) {
  final units = context
      .select<SettingsBloc, (TemperatureUnit, WindUnit, PressureUnit)>(
        (bloc) => (
          bloc.state.settings.temperatureUnit,
          bloc.state.settings.windUnit,
          bloc.state.settings.pressureUnit,
        ),
      );
  return Formats(
    context.l10n,
    temperatureUnit: units.$1,
    windUnit: units.$2,
    pressureUnit: units.$3,
  );
}
