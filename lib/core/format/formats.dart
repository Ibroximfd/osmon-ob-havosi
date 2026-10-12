import '../domain/units.dart';
import '../domain/weather_condition.dart';
import '../l10n/l10n.dart';

/// Turns domain values into display strings for the active language and the
/// user's units. Built per build from `context.l10n` and the settings slice;
/// it holds no state of its own.
final class Formats {
  const Formats(
    this.l10n, {
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windUnit = WindUnit.kilometresPerHour,
    this.pressureUnit = PressureUnit.hectopascal,
  });

  final AppLocalizations l10n;
  final TemperatureUnit temperatureUnit;
  final WindUnit windUnit;
  final PressureUnit pressureUnit;

  /// `23°` — the unit letter is implied by the settings.
  String temperature(double celsius) =>
      '${UnitConversion.temperature(celsius, temperatureUnit).round()}°';

  /// Bare number for the hero, where the degree sign is styled separately.
  String temperatureValue(double celsius) =>
      '${UnitConversion.temperature(celsius, temperatureUnit).round()}';

  String temperatureDelta(double celsiusDelta) {
    final converted = temperatureUnit == TemperatureUnit.fahrenheit
        ? celsiusDelta * 9 / 5
        : celsiusDelta;
    final rounded = converted.round();
    return '${rounded > 0 ? '+' : ''}$rounded°';
  }

  String windValue(double kilometresPerHour) {
    final value = UnitConversion.wind(kilometresPerHour, windUnit);
    return windUnit == WindUnit.metresPerSecond
        ? value.toStringAsFixed(value < 10 ? 1 : 0)
        : value.round().toString();
  }

  String get windUnitLabel => switch (windUnit) {
    WindUnit.kilometresPerHour => l10n.unitKmh,
    WindUnit.metresPerSecond => l10n.unitMs,
  };

  String wind(double kilometresPerHour) =>
      '${windValue(kilometresPerHour)} $windUnitLabel';

  String pressureValue(double hectopascal) =>
      UnitConversion.pressure(hectopascal, pressureUnit).round().toString();

  String get pressureUnitLabel => switch (pressureUnit) {
    PressureUnit.hectopascal => l10n.unitHpa,
    PressureUnit.millimetreMercury => l10n.unitMmHg,
  };

  String pressureDelta(double hectopascalDelta) {
    final value = UnitConversion.pressure(hectopascalDelta, pressureUnit);
    final rounded = value.round();
    return '${rounded > 0 ? '+' : ''}$rounded';
  }

  String percent(num value) => l10n.unitPercent(value.round().toString());

  /// 24-hour `HH:mm`, the convention across the region.
  String time(DateTime value) => '${_two(value.hour)}:${_two(value.minute)}';

  String hour(DateTime value) => '${_two(value.hour)}:00';

  String weekday(DateTime value) => switch (value.weekday) {
    DateTime.monday => l10n.weekday1,
    DateTime.tuesday => l10n.weekday2,
    DateTime.wednesday => l10n.weekday3,
    DateTime.thursday => l10n.weekday4,
    DateTime.friday => l10n.weekday5,
    DateTime.saturday => l10n.weekday6,
    _ => l10n.weekday7,
  };

  String weekdayShort(DateTime value) => switch (value.weekday) {
    DateTime.monday => l10n.weekdayShort1,
    DateTime.tuesday => l10n.weekdayShort2,
    DateTime.wednesday => l10n.weekdayShort3,
    DateTime.thursday => l10n.weekdayShort4,
    DateTime.friday => l10n.weekdayShort5,
    DateTime.saturday => l10n.weekdayShort6,
    _ => l10n.weekdayShort7,
  };

  String month(int month) => switch (month) {
    1 => l10n.month1,
    2 => l10n.month2,
    3 => l10n.month3,
    4 => l10n.month4,
    5 => l10n.month5,
    6 => l10n.month6,
    7 => l10n.month7,
    8 => l10n.month8,
    9 => l10n.month9,
    10 => l10n.month10,
    11 => l10n.month11,
    _ => l10n.month12,
  };

  String dayMonth(DateTime value) =>
      l10n.dateDayMonth(value.day.toString(), month(value.month));

  /// "Today", "Tomorrow", then weekday names. Compares calendar dates, so
  /// passing "now" (with a time of day) works too.
  String dayLabel(DateTime day, DateTime today) {
    final difference = DateTime.utc(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.tomorrow;
    return weekday(day);
  }

  String duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return l10n.durationMinutes(minutes);
    if (minutes == 0) return l10n.durationHours(hours);
    return l10n.durationHoursMinutes(hours.toString(), minutes.toString());
  }

  String condition(WeatherCondition value) => switch (value) {
    WeatherCondition.clear => l10n.conditionClear,
    WeatherCondition.mainlyClear => l10n.conditionMainlyClear,
    WeatherCondition.partlyCloudy => l10n.conditionPartlyCloudy,
    WeatherCondition.overcast => l10n.conditionOvercast,
    WeatherCondition.fog => l10n.conditionFog,
    WeatherCondition.drizzle => l10n.conditionDrizzle,
    WeatherCondition.freezingDrizzle => l10n.conditionFreezingDrizzle,
    WeatherCondition.rain => l10n.conditionRain,
    WeatherCondition.heavyRain => l10n.conditionHeavyRain,
    WeatherCondition.freezingRain => l10n.conditionFreezingRain,
    WeatherCondition.rainShowers => l10n.conditionRainShowers,
    WeatherCondition.snow => l10n.conditionSnow,
    WeatherCondition.heavySnow => l10n.conditionHeavySnow,
    WeatherCondition.snowShowers => l10n.conditionSnowShowers,
    WeatherCondition.thunderstorm => l10n.conditionThunderstorm,
    WeatherCondition.thunderstormHail => l10n.conditionThunderstormHail,
  };

  static String _two(int value) => value.toString().padLeft(2, '0');
}
