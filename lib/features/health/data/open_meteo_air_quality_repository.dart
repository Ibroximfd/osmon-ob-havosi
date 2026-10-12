import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/domain/place.dart';
import '../../../core/domain/place_time.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/air_quality.dart';
import '../domain/air_quality_repository.dart';

final class OpenMeteoAirQualityRepository implements AirQualityRepository {
  const OpenMeteoAirQualityRepository(this._http);

  final Dio _http;

  static const Map<PollenType, String> _pollenFields = <PollenType, String>{
    PollenType.alder: 'alder_pollen',
    PollenType.birch: 'birch_pollen',
    PollenType.grass: 'grass_pollen',
    PollenType.mugwort: 'mugwort_pollen',
    PollenType.olive: 'olive_pollen',
    PollenType.ragweed: 'ragweed_pollen',
  };

  static final String _fields = <String>[
    'us_aqi',
    'pm10',
    'pm2_5',
    'nitrogen_dioxide',
    'ozone',
    'dust',
    ..._pollenFields.values,
  ].join(',');

  @override
  Future<Either<DataFailure, AirQualityReport>> loadReport(Place place) =>
      guard(() async {
        final response = await _http.get<Map<String, dynamic>>(
          ApiEndpoints.airQuality,
          queryParameters: <String, Object>{
            'latitude': place.point.latitude,
            'longitude': place.point.longitude,
            'current': _fields,
            'hourly': _fields,
            'forecast_days': 3,
            'timezone': 'auto',
          },
        );
        final json =
            response.data ?? (throw const FormatException('empty air'));
        final hourly = json.object('hourly');
        final times = hourly.list('time');
        return AirQualityReport(
          current: _reading(json.object('current')),
          hourly: <AirReading>[
            for (var i = 0; i < times.length; i++) _hourReading(hourly, i),
          ],
        );
      });

  static AirReading _reading(Map<String, dynamic> c) => AirReading(
    time: parsePlaceTime(c.text('time')),
    usAqi: c.numberOrNull('us_aqi'),
    pm25: c.numberOrNull('pm2_5'),
    pm10: c.numberOrNull('pm10'),
    nitrogenDioxide: c.numberOrNull('nitrogen_dioxide'),
    ozone: c.numberOrNull('ozone'),
    dust: c.numberOrNull('dust'),
    pollen: <PollenType, double>{
      for (final entry in _pollenFields.entries)
        entry.key: ?c.numberOrNull(entry.value),
    },
  );

  static AirReading _hourReading(Map<String, dynamic> h, int i) => AirReading(
    time: parsePlaceTime(h.list('time').textAt(i)),
    usAqi: h.list('us_aqi').numberOrNullAt(i),
    pm25: h.list('pm2_5').numberOrNullAt(i),
    pm10: h.list('pm10').numberOrNullAt(i),
    dust: h.list('dust').numberOrNullAt(i),
    pollen: <PollenType, double>{
      for (final entry in _pollenFields.entries)
        entry.key: ?h.listOrNull(entry.value)?.numberOrNullAt(i),
    },
  );
}
