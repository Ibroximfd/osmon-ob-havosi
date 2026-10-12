import 'package:timezone/timezone.dart' as tz;

import '../domain/time_zone_resolver.dart';

/// Uses the bundled IANA database (initialised in bootstrap).
final class TzTimeZoneResolver implements TimeZoneResolver {
  const TzTimeZoneResolver();

  @override
  int offsetSecondsFor(String? timezoneId, DateTime utcInstant) {
    if (timezoneId != null) {
      try {
        final location = tz.getLocation(timezoneId);
        return location.timeZone(utcInstant.millisecondsSinceEpoch).offset ~/
            1000;
      } on tz.LocationNotFoundException {
        // Unknown id: fall through to the device's own offset.
      }
    }
    return utcInstant.toLocal().timeZoneOffset.inSeconds;
  }
}
