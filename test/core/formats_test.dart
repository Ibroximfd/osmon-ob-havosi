import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/units.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/format/formats.dart';
import 'package:osmon_uzbekiston_ob_havosi/l10n/app_localizations.dart';
import 'package:osmon_uzbekiston_ob_havosi/l10n/app_localizations_uz.dart';

void main() {
  final AppLocalizations l10n = AppLocalizationsUz();
  final formats = Formats(l10n);

  test('tomorrow is tomorrow even when "today" carries a time', () {
    final afternoon = DateTime.utc(2026, 10, 12, 14, 1);
    expect(formats.dayLabel(DateTime.utc(2026, 10, 12), afternoon), l10n.today);
    expect(
      formats.dayLabel(DateTime.utc(2026, 10, 13), afternoon),
      l10n.tomorrow,
    );
    expect(
      formats.dayLabel(DateTime.utc(2026, 10, 14), afternoon),
      l10n.weekday3,
    );
  });

  test('units convert from the stored metric values', () {
    final imperial = Formats(
      l10n,
      temperatureUnit: TemperatureUnit.fahrenheit,
      windUnit: WindUnit.metresPerSecond,
      pressureUnit: PressureUnit.millimetreMercury,
    );
    expect(imperial.temperature(20), '68°');
    expect(imperial.windValue(36), '10');
    expect(imperial.pressureValue(1013), '760');
  });

  test('durations read naturally', () {
    expect(formats.duration(const Duration(minutes: 95)), '1 soat 35 daq');
    expect(formats.duration(const Duration(minutes: 40)), '40 daqiqa');
  });
}
