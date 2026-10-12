import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/json_reader.dart';

final class UpdateOffer {
  const UpdateOffer({
    required this.version,
    required this.storeUrl,
    required this.isForced,
  });

  final String version;
  final String storeUrl;
  final bool isForced;
}

/// Reads the version manifest hosted on GitHub Pages. Any failure means
/// "no offer" — an update prompt is never worth an error on screen.
final class UpdateChecker {
  const UpdateChecker(this._http, this._prefs);

  final Dio _http;
  final SharedPreferences _prefs;

  static const String _dismissedKey = 'v2.update_dismissed';

  Future<UpdateOffer?> check() async {
    try {
      final response = await _http.get<Map<String, dynamic>>(
        ApiEndpoints.versionManifest,
        options: Options(receiveTimeout: const Duration(seconds: 6)),
      );
      final json = response.data;
      if (json == null) return null;
      final latest = json.textOrNull('latest_version') ?? '0.0.0';
      final minimum = json.textOrNull('min_version') ?? '0.0.0';
      final current = (await PackageInfo.fromPlatform()).version;
      final isForced =
          json['force_update'] == true || compareVersions(current, minimum) < 0;
      final isNewer = compareVersions(current, latest) < 0;
      if (!isNewer && !isForced) return null;
      if (!isForced && _prefs.getString(_dismissedKey) == latest) return null;
      return UpdateOffer(
        version: latest,
        storeUrl: json.textOrNull('play_store_url') ?? ApiEndpoints.playStore,
        isForced: isForced,
      );
    } on DioException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<void> dismiss(UpdateOffer offer) =>
      _prefs.setString(_dismissedKey, offer.version);
}

/// Negative when [a] is older than [b].
int compareVersions(String a, String b) {
  List<int> parts(String v) =>
      v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final left = parts(a);
  final right = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < left.length ? left[i] : 0;
    final y = i < right.length ? right[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}
