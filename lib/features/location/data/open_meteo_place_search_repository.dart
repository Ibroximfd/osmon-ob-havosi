import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/domain/geo_point.dart';
import '../../../core/domain/place.dart';
import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../domain/place_search_repository.dart';

final class OpenMeteoPlaceSearchRepository implements PlaceSearchRepository {
  const OpenMeteoPlaceSearchRepository(this._http);

  final Dio _http;

  static const int _resultLimit = 12;

  @override
  Future<Either<DataFailure, List<Place>>> search(
    String query, {
    required String languageCode,
  }) => guard(() async {
    final response = await _http.get<Map<String, dynamic>>(
      ApiEndpoints.geocoding,
      queryParameters: <String, Object>{
        'name': query.trim(),
        'count': _resultLimit,
        'language': languageCode,
        'format': 'json',
      },
    );
    final results = response.data?.listOrNull('results') ?? const <dynamic>[];
    return results
        .whereType<Map<String, dynamic>>()
        .map(_toPlace)
        .toList(growable: false);
  });

  static Place _toPlace(Map<String, dynamic> json) => Place(
    name: json.text('name'),
    point: GeoPoint(json.number('latitude'), json.number('longitude')),
    region: json.textOrNull('admin1'),
    countryCode: json.textOrNull('country_code')?.toUpperCase(),
    timezoneId: json.textOrNull('timezone'),
  );
}
