import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../../core/domain/geo_point.dart';

/// Sun and moon facts for one day at one place, computed offline with the
/// NOAA low-precision solar formulas (accurate to about a minute here).
final class SunDay extends Equatable {
  const SunDay({
    required this.sunrise,
    required this.sunset,
    required this.solarNoon,
    required this.morningBlueHour,
    required this.morningGoldenHour,
    required this.eveningGoldenHour,
    required this.eveningBlueHour,
  });

  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime solarNoon;
  final TimeWindow? morningBlueHour;
  final TimeWindow? morningGoldenHour;
  final TimeWindow? eveningGoldenHour;
  final TimeWindow? eveningBlueHour;

  Duration? get daylight =>
      sunrise == null || sunset == null ? null : sunset!.difference(sunrise!);

  /// 0 at sunrise, 1 at sunset; null outside daylight.
  double? progressAt(DateTime now) {
    final rise = sunrise;
    final set = sunset;
    if (rise == null || set == null) return null;
    if (now.isBefore(rise) || now.isAfter(set)) return null;
    return now.difference(rise).inSeconds / set.difference(rise).inSeconds;
  }

  @override
  List<Object?> get props => <Object?>[
    sunrise,
    sunset,
    solarNoon,
    morningBlueHour,
    morningGoldenHour,
    eveningGoldenHour,
    eveningBlueHour,
  ];
}

final class TimeWindow extends Equatable {
  const TimeWindow(this.start, this.end);

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => <Object?>[start, end];
}

/// Sun altitude (degrees) at the horizon accounting for refraction and disc.
const double _horizon = -0.833;
const double _goldenTop = 6;
const double _goldenBottom = -4;
const double _blueBottom = -6;

SunDay sunDayFor(GeoPoint point, DateTime date, int utcOffsetSeconds) {
  final solar = _SolarPosition.forDate(date, utcOffsetSeconds);
  final offsetHours = utcOffsetSeconds / 3600;
  final noonHours =
      12 +
      offsetHours -
      point.longitude / 15 -
      solar.equationOfTimeMinutes / 60;

  DateTime at(double hours) => DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).add(Duration(seconds: (hours * 3600).round()));

  DateTime? crossing(double altitude, {required bool morning}) {
    final hourAngle = _hourAngleHours(
      altitude,
      point.latitude,
      solar.declination,
    );
    if (hourAngle == null) return null;
    return at(morning ? noonHours - hourAngle : noonHours + hourAngle);
  }

  TimeWindow? window(double from, double to, {required bool morning}) {
    final a = crossing(from, morning: morning);
    final b = crossing(to, morning: morning);
    if (a == null || b == null) return null;
    return a.isBefore(b) ? TimeWindow(a, b) : TimeWindow(b, a);
  }

  return SunDay(
    sunrise: crossing(_horizon, morning: true),
    sunset: crossing(_horizon, morning: false),
    solarNoon: at(noonHours),
    morningBlueHour: window(_blueBottom, _goldenBottom, morning: true),
    morningGoldenHour: window(_goldenBottom, _goldenTop, morning: true),
    eveningGoldenHour: window(_goldenTop, _goldenBottom, morning: false),
    eveningBlueHour: window(_goldenBottom, _blueBottom, morning: false),
  );
}

double? _hourAngleHours(double altitude, double latitude, double declination) {
  final lat = latitude * math.pi / 180;
  final cosH =
      (math.sin(altitude * math.pi / 180) -
          math.sin(lat) * math.sin(declination)) /
      (math.cos(lat) * math.cos(declination));
  if (cosH < -1 || cosH > 1) return null;
  return math.acos(cosH) * 180 / math.pi / 15;
}

final class _SolarPosition {
  const _SolarPosition(this.declination, this.equationOfTimeMinutes);

  /// Radians.
  final double declination;
  final double equationOfTimeMinutes;

  factory _SolarPosition.forDate(DateTime date, int utcOffsetSeconds) {
    final noonUtc = DateTime.utc(
      date.year,
      date.month,
      date.day,
      12,
    ).subtract(Duration(seconds: utcOffsetSeconds));
    final n = _daysSinceJ2000(noonUtc);
    final meanLongitude = (280.460 + 0.9856474 * n) % 360;
    final anomaly = ((357.528 + 0.9856003 * n) % 360) * math.pi / 180;
    final eclipticLongitude =
        (meanLongitude +
            1.915 * math.sin(anomaly) +
            0.020 * math.sin(2 * anomaly)) *
        math.pi /
        180;
    final obliquity = (23.439 - 0.0000004 * n) * math.pi / 180;
    final declination = math.asin(
      math.sin(obliquity) * math.sin(eclipticLongitude),
    );
    var rightAscension =
        math.atan2(
          math.cos(obliquity) * math.sin(eclipticLongitude),
          math.cos(eclipticLongitude),
        ) *
        180 /
        math.pi;
    rightAscension = (rightAscension + 360) % 360;
    var difference = meanLongitude - rightAscension;
    if (difference > 180) difference -= 360;
    if (difference < -180) difference += 360;
    return _SolarPosition(declination, difference * 4);
  }
}

double _daysSinceJ2000(DateTime utc) =>
    utc.difference(DateTime.utc(2000, 1, 1, 12)).inSeconds / 86400;

enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

final class MoonPhase extends Equatable {
  const MoonPhase({required this.age, required this.illumination});

  static const double synodicMonth = 29.530588853;

  /// Days since the last new moon.
  final double age;

  /// 0–1 fraction of the disc lit.
  final double illumination;

  bool get isWaxing => age < synodicMonth / 2;

  MoonPhaseName get name {
    final eighth = synodicMonth / 8;
    final index = ((age + eighth / 2) / eighth).floor() % 8;
    return MoonPhaseName.values[index];
  }

  @override
  List<Object?> get props => <Object?>[age, illumination];
}

/// Reference new moon: 2000-01-06 18:14 UTC.
MoonPhase moonPhaseAt(DateTime utcInstant) {
  final reference = DateTime.utc(2000, 1, 6, 18, 14);
  final days = utcInstant.difference(reference).inSeconds / 86400;
  final age = days % MoonPhase.synodicMonth;
  final fraction = age / MoonPhase.synodicMonth;
  return MoonPhase(
    age: age,
    illumination: (1 - math.cos(2 * math.pi * fraction)) / 2,
  );
}
