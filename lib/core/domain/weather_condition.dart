/// WMO weather interpretation codes, collapsed into the conditions the app
/// renders differently. The raw code never leaves the data layer.
enum WeatherCondition {
  clear,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  freezingDrizzle,
  rain,
  heavyRain,
  freezingRain,
  rainShowers,
  snow,
  heavySnow,
  snowShowers,
  thunderstorm,
  thunderstormHail;

  static WeatherCondition fromWmo(int code) => switch (code) {
    0 => clear,
    1 => mainlyClear,
    2 => partlyCloudy,
    3 => overcast,
    45 || 48 => fog,
    51 || 53 || 55 => drizzle,
    56 || 57 => freezingDrizzle,
    61 || 63 => rain,
    65 => heavyRain,
    66 || 67 => freezingRain,
    71 || 73 || 77 => snow,
    75 => heavySnow,
    80 || 81 || 82 => rainShowers,
    85 || 86 => snowShowers,
    95 => thunderstorm,
    96 || 99 => thunderstormHail,
    _ => overcast,
  };

  bool get isWet => switch (this) {
    drizzle ||
    freezingDrizzle ||
    rain ||
    heavyRain ||
    freezingRain ||
    rainShowers ||
    thunderstorm ||
    thunderstormHail => true,
    _ => false,
  };

  bool get isSnowy => this == snow || this == heavySnow || this == snowShowers;

  bool get isStormy => this == thunderstorm || this == thunderstormHail;

  bool get isCloudy => this == partlyCloudy || this == overcast;

  bool get isClearSky => this == clear || this == mainlyClear;
}
