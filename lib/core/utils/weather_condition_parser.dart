class WeatherConditionParser {
  static String getWeatherCondition(int code) {
    if (code == 0) return 'Ochiq havo';
    if (code == 1 || code == 2 || code == 3) return 'Qisman bulutli';
    if (code >= 45 && code <= 48) return 'Tuman';
    if (code >= 51 && code <= 67) return 'Yomg\'ir';
    if (code >= 71 && code <= 77) return 'Qor';
    if (code >= 80 && code <= 82) return 'Kuchli yomg\'ir';
    if (code >= 95 && code <= 99) return 'Momaqaldiroq';
    return 'Noma\'lum';
  }
}
