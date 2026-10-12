/// Times in this app are "place wall-clock" values: a `DateTime.utc` whose
/// fields read as the local time *at the place* (Open-Meteo returns local
/// times for `timezone=auto`). Comparing them with [placeNow] keeps every
/// countdown correct even when the phone sits in another time zone.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();

DateTime placeNow(int utcOffsetSeconds, {Clock clock = systemClock}) =>
    clock().toUtc().add(Duration(seconds: utcOffsetSeconds));

/// Parses Open-Meteo's `2026-10-11T14:00` into a place wall-clock value.
DateTime parsePlaceTime(String iso) {
  final parsed = DateTime.parse(iso);
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
  );
}

extension PlaceDate on DateTime {
  DateTime get dateOnly => DateTime.utc(year, month, day);

  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
