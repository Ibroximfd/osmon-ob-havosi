import 'package:dio/dio.dart';

/// The single configured HTTP client. Data sources pass absolute URLs from
/// `ApiEndpoints`, so one instance serves every host.
Dio createHttpClient() => Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
    headers: const <String, String>{
      // OSRM and OpenFreeMap ask clients to identify themselves.
      'User-Agent': 'Osmon/2.0 (uz.osmon.osmon_uzbekiston_ob_havosi)',
    },
  ),
);
