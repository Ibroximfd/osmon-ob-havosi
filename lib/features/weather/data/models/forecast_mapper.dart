import '../../../../core/domain/place.dart';
import '../../../../core/domain/place_time.dart';
import '../../../../core/domain/weather_condition.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/forecast.dart';

/// Maps the Open-Meteo forecast payload (parallel arrays) onto entities,
/// anchored at [now] in place time: hourly starts at the current hour and
/// the hours before it become the pressure history. Re-running it on a
/// cached payload therefore re-anchors stale data correctly.
Forecast mapForecast({
  required Map<String, dynamic> json,
  required Map<String, dynamic>? airJson,
  required Place place,
  required DateTime Function(int utcOffsetSeconds) nowAt,
}) {
  final offset = json.number('utc_offset_seconds').round();
  final now = nowAt(offset);
  final hourly = json.object('hourly');
  final times = hourly.list('time');

  var nowIndex = 0;
  for (var i = 0; i < times.length; i++) {
    final time = parsePlaceTime(times.textAt(i));
    if (time.isAfter(now)) break;
    nowIndex = i;
  }

  final pressures = hourly.list('pressure_msl');
  final history = <PressureSample>[
    for (var i = (nowIndex - 24).clamp(0, nowIndex); i <= nowIndex; i++)
      if (pressures.numberOrNullAt(i) != null)
        PressureSample(
          time: parsePlaceTime(times.textAt(i)),
          pressure: pressures.numberAt(i),
        ),
  ];

  return Forecast(
    place: place.copyWith(timezoneId: json.textOrNull('timezone')),
    fetchedAt: now,
    utcOffsetSeconds: offset,
    timezoneId: json.textOrNull('timezone') ?? 'UTC',
    current: _current(json.object('current')),
    hourly: <HourlyWeather>[
      // The model's horizon ends a few hours before the last timestamp;
      // those trailing hours come back as nulls and are dropped.
      for (var i = nowIndex; i < times.length && _hasCore(hourly, i); i++)
        _hour(hourly, i),
    ],
    daily: _daily(json.object('daily')),
    nowcast: _nowcast(json.objectOrNull('minutely_15')),
    pressureHistory: history,
    air: airJson == null ? null : _air(airJson.objectOrNull('current')),
  );
}

CurrentWeather _current(Map<String, dynamic> c) => CurrentWeather(
  time: parsePlaceTime(c.text('time')),
  temperature: c.number('temperature_2m'),
  apparentTemperature: c.number('apparent_temperature'),
  condition: WeatherCondition.fromWmo(c.number('weather_code').round()),
  isDay: c.number('is_day') == 1,
  humidity: c.number('relative_humidity_2m'),
  dewPoint: c.numberOrNull('dew_point_2m') ?? c.number('temperature_2m'),
  windSpeed: c.number('wind_speed_10m'),
  windDirection: c.numberOrNull('wind_direction_10m') ?? 0,
  windGusts: c.numberOrNull('wind_gusts_10m') ?? c.number('wind_speed_10m'),
  pressure: c.number('pressure_msl'),
  cloudCover: c.numberOrNull('cloud_cover') ?? 0,
  visibility: c.numberOrNull('visibility') ?? 0,
  uvIndex: c.numberOrNull('uv_index') ?? 0,
  precipitation: c.numberOrNull('precipitation') ?? 0,
);

bool _hasCore(Map<String, dynamic> h, int i) =>
    h.list('temperature_2m').numberOrNullAt(i) != null &&
    h.list('weather_code').numberOrNullAt(i) != null;

HourlyWeather _hour(Map<String, dynamic> h, int i) => HourlyWeather(
  time: parsePlaceTime(h.list('time').textAt(i)),
  temperature: h.list('temperature_2m').numberAt(i),
  apparentTemperature:
      h.list('apparent_temperature').numberOrNullAt(i) ??
      h.list('temperature_2m').numberAt(i),
  condition: WeatherCondition.fromWmo(
    h.list('weather_code').numberAt(i).round(),
  ),
  isDay: h.list('is_day').numberOrNullAt(i) == 1,
  precipitationProbability:
      h.list('precipitation_probability').numberOrNullAt(i) ?? 0,
  precipitation: h.list('precipitation').numberOrNullAt(i) ?? 0,
  windSpeed: h.list('wind_speed_10m').numberOrNullAt(i) ?? 0,
  windGusts: h.list('wind_gusts_10m').numberOrNullAt(i) ?? 0,
  uvIndex: h.list('uv_index').numberOrNullAt(i) ?? 0,
  visibility: h.list('visibility').numberOrNullAt(i) ?? 0,
  cloudCover: h.list('cloud_cover').numberOrNullAt(i) ?? 0,
  humidity: h.list('relative_humidity_2m').numberOrNullAt(i) ?? 0,
);

List<DailyWeather> _daily(Map<String, dynamic> d) {
  final dates = d.list('time');
  return <DailyWeather>[
    for (var i = 0; i < dates.length; i++)
      if (d.list('temperature_2m_min').numberOrNullAt(i) != null &&
          d.list('temperature_2m_max').numberOrNullAt(i) != null &&
          d.list('weather_code').numberOrNullAt(i) != null)
        DailyWeather(
          date: parsePlaceTime(dates.textAt(i)),
          minTemperature: d.list('temperature_2m_min').numberAt(i),
          maxTemperature: d.list('temperature_2m_max').numberAt(i),
          condition: WeatherCondition.fromWmo(
            d.list('weather_code').numberAt(i).round(),
          ),
          precipitationProbability:
              d.list('precipitation_probability_max').numberOrNullAt(i) ?? 0,
          precipitationSum: d.list('precipitation_sum').numberOrNullAt(i) ?? 0,
          snowfallSum: d.list('snowfall_sum').numberOrNullAt(i) ?? 0,
          sunrise: parsePlaceTime(d.list('sunrise').textAt(i)),
          sunset: parsePlaceTime(d.list('sunset').textAt(i)),
          uvIndexMax: d.list('uv_index_max').numberOrNullAt(i) ?? 0,
          windSpeedMax: d.list('wind_speed_10m_max').numberOrNullAt(i) ?? 0,
          windGustsMax: d.list('wind_gusts_10m_max').numberOrNullAt(i) ?? 0,
        ),
  ];
}

List<NowcastStep> _nowcast(Map<String, dynamic>? m) {
  if (m == null) return const <NowcastStep>[];
  final times = m.list('time');
  final amounts = m.list('precipitation');
  return <NowcastStep>[
    for (var i = 0; i < times.length; i++)
      NowcastStep(
        time: parsePlaceTime(times.textAt(i)),
        precipitation: amounts.numberOrNullAt(i) ?? 0,
      ),
  ];
}

AirSnapshot? _air(Map<String, dynamic>? a) {
  if (a == null) return null;
  return AirSnapshot(
    usAqi: a.numberOrNull('us_aqi'),
    pm10: a.numberOrNull('pm10'),
    pm25: a.numberOrNull('pm2_5'),
    dust: a.numberOrNull('dust'),
  );
}
