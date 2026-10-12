/// Every external host the app talks to. All of them are keyless except
/// Gemini, whose key lives in [geminiApiKey].
abstract final class ApiEndpoints {
  static const String forecast = 'https://api.open-meteo.com/v1/forecast';
  static const String airQuality =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const String archive = 'https://archive-api.open-meteo.com/v1/archive';
  static const String geocoding =
      'https://geocoding-api.open-meteo.com/v1/search';

  /// OSRM public demo server: road geometry for the route-weather feature.
  /// Used once per user-initiated route; a straight-line estimate is the
  /// fallback when it is unavailable.
  static const String osrmRoute =
      'https://router.project-osrm.org/route/v1/driving';

  /// OpenFreeMap TileJSON. The tile URL inside is versioned weekly, so it is
  /// resolved at runtime instead of being hardcoded.
  static const String openFreeMapTileJson =
      'https://tiles.openfreemap.org/planet';

  static const String gemini =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String geminiTextModel = 'gemini-2.5-flash';
  static const String geminiImageModel =
      'gemini-2.0-flash-exp-image-generation';

  /// Replace with a real key in release builds; while it is the placeholder
  /// the AI features render their "not configured" state instead of failing.
  static const String geminiApiKey = 'Api Key';

  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'Api Key';

  static const String versionManifest =
      'https://ibroximfd.github.io/osmon-version.json';
  static const String privacyPolicy =
      'https://ibroximfd.github.io/osmon-legal/';
  static const String playStore =
      'https://play.google.com/store/apps/details?id=uz.osmon.osmon_uzbekiston_ob_havosi';
}
