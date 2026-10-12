/// UTC offset of a place's time zone at a given instant.
abstract interface class TimeZoneResolver {
  /// Falls back to the device's offset when [timezoneId] is unknown.
  int offsetSecondsFor(String? timezoneId, DateTime utcInstant);
}
