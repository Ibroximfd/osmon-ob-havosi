import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/place.dart';
import '../../../core/domain/place_time.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/field_conditions.dart';
import '../domain/field_repository.dart';

final class OpenMeteoFieldRepository implements FieldRepository {
  const OpenMeteoFieldRepository(
    this._http,
    this._prefs, {
    Clock clock = systemClock,
  }) : _clock = clock;

  final Dio _http;
  final SharedPreferences _prefs;
  final Clock _clock;

  static const String _cropKey = 'v2.field_crop';
  static const int _pastDays = 7;
  static const int _hoursAhead = 72;

  @override
  Crop get savedCrop {
    final name = _prefs.getString(_cropKey);
    return Crop.values.where((c) => c.name == name).firstOrNull ?? Crop.wheat;
  }

  @override
  Future<void> saveCrop(Crop crop) => _prefs.setString(_cropKey, crop.name);

  @override
  Future<Either<DataFailure, FieldConditions>> loadConditions(Place place) =>
      guard(() async {
        final forecast = await _fetchForecast(place);
        final offset = forecast.number('utc_offset_seconds').round();
        final now = placeNow(offset, clock: _clock);
        final allDays = _days(forecast.object('daily'));
        final todayIndex = allDays.indexWhere((d) => d.date.isSameDayAs(now));
        final upcoming = todayIndex < 0 ? allDays : allDays.sublist(todayIndex);
        final recent = todayIndex < 0
            ? const <FieldDay>[]
            : allDays.sublist(0, todayIndex + 1);
        final hourly = forecast.object('hourly');
        final nowIndex = _nowIndex(hourly.list('time'), now);
        final current = _hourValues(hourly, nowIndex);
        return FieldConditions(
          now: now,
          soilTemperatureSurface: current.soilSurface,
          soilTemperatureRoot: current.soilRoot,
          soilMoisture: current.moisture,
          hours: <FieldHour>[
            for (
              var i = nowIndex;
              i < hourly.list('time').length && i < nowIndex + _hoursAhead;
              i++
            )
              _hour(hourly, i),
          ],
          days: upcoming,
          season: await _season(place, now, recent),
        );
      });

  Future<Map<String, dynamic>> _fetchForecast(Place place) async {
    final response = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.forecast,
      queryParameters: <String, Object>{
        'latitude': place.point.latitude,
        'longitude': place.point.longitude,
        'hourly':
            'temperature_2m,wind_speed_10m,wind_gusts_10m,'
            'precipitation_probability,is_day,soil_temperature_0cm,'
            'soil_temperature_6cm,soil_moisture_1_to_3cm',
        'daily':
            'temperature_2m_min,temperature_2m_max,precipitation_sum,'
            'precipitation_probability_max,et0_fao_evapotranspiration',
        'past_days': _pastDays,
        'forecast_days': 7,
        'timezone': 'auto',
      },
    );
    return response.data ?? (throw const FormatException('empty field'));
  }

  /// Daily temperatures from 1 March up to today: the archive covers the
  /// older part, the forecast's `past_days` the most recent week.
  Future<List<FieldDay>> _season(
    Place place,
    DateTime now,
    List<FieldDay> recent,
  ) async {
    final start = DateTime.utc(now.year, 3, 1);
    if (now.isBefore(start)) return const <FieldDay>[];
    final archiveEnd = now.subtract(const Duration(days: _pastDays + 1));
    final inSeason = recent.where((d) => !d.date.isBefore(start)).toList();
    if (archiveEnd.isBefore(start)) return inSeason;
    final response = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.archive,
      queryParameters: <String, Object>{
        'latitude': place.point.latitude,
        'longitude': place.point.longitude,
        'start_date': _iso(start),
        'end_date': _iso(archiveEnd),
        'daily': 'temperature_2m_min,temperature_2m_max',
        'timezone': 'auto',
      },
    );
    final json = response.data ?? (throw const FormatException('empty season'));
    return <FieldDay>[..._days(json.object('daily')), ...inSeason];
  }

  static int _nowIndex(List<dynamic> times, DateTime now) {
    var index = 0;
    for (var i = 0; i < times.length; i++) {
      if (parsePlaceTime(times.textAt(i)).isAfter(now)) break;
      index = i;
    }
    return index;
  }

  static ({double soilSurface, double soilRoot, double moisture}) _hourValues(
    Map<String, dynamic> h,
    int i,
  ) => (
    soilSurface: h.list('soil_temperature_0cm').numberOrNullAt(i) ?? 0,
    soilRoot: h.list('soil_temperature_6cm').numberOrNullAt(i) ?? 0,
    moisture: h.list('soil_moisture_1_to_3cm').numberOrNullAt(i) ?? 0,
  );

  static FieldHour _hour(Map<String, dynamic> h, int i) => FieldHour(
    time: parsePlaceTime(h.list('time').textAt(i)),
    temperature: h.list('temperature_2m').numberOrNullAt(i) ?? 0,
    windSpeed: h.list('wind_speed_10m').numberOrNullAt(i) ?? 0,
    windGusts: h.list('wind_gusts_10m').numberOrNullAt(i) ?? 0,
    precipitationProbability:
        h.list('precipitation_probability').numberOrNullAt(i) ?? 0,
    isDay: h.list('is_day').numberOrNullAt(i) == 1,
  );

  static List<FieldDay> _days(Map<String, dynamic> d) {
    final dates = d.list('time');
    final min = d.list('temperature_2m_min');
    final max = d.list('temperature_2m_max');
    return <FieldDay>[
      for (var i = 0; i < dates.length; i++)
        if (min.numberOrNullAt(i) != null && max.numberOrNullAt(i) != null)
          FieldDay(
            date: parsePlaceTime(dates.textAt(i)),
            minTemperature: min.numberAt(i),
            maxTemperature: max.numberAt(i),
            precipitationSum:
                d.listOrNull('precipitation_sum')?.numberOrNullAt(i) ?? 0,
            precipitationProbability:
                d
                    .listOrNull('precipitation_probability_max')
                    ?.numberOrNullAt(i) ??
                0,
            evapotranspiration:
                d.listOrNull('et0_fao_evapotranspiration')?.numberOrNullAt(i) ??
                0,
          ),
    ];
  }

  static String _iso(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
