class ApiConstants {
  ApiConstants._();

  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';
  static const String airQualityBaseUrl =
      'https://air-quality-api.open-meteo.com/v1';
  static const String forecastPath = '/forecast';
  static const String airQualityPath = '/air-quality';
  static const String defaultTimezone = 'Asia/Tashkent';

  static const String geminiApiKey = 'AIzaSyDeS-lRnkd0JAaOttb_IrgCQkTh8EUMAi4';
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
}
