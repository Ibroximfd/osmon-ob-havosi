enum TemperatureUnit { celsius, fahrenheit }

enum WindUnit { kilometresPerHour, metresPerSecond }

enum PressureUnit { hectopascal, millimetreMercury }

/// Conversions from the metric values the data layer always stores.
abstract final class UnitConversion {
  static double temperature(double celsius, TemperatureUnit unit) =>
      switch (unit) {
        TemperatureUnit.celsius => celsius,
        TemperatureUnit.fahrenheit => celsius * 9 / 5 + 32,
      };

  static double wind(double kilometresPerHour, WindUnit unit) => switch (unit) {
    WindUnit.kilometresPerHour => kilometresPerHour,
    WindUnit.metresPerSecond => kilometresPerHour / 3.6,
  };

  static double pressure(double hectopascal, PressureUnit unit) =>
      switch (unit) {
        PressureUnit.hectopascal => hectopascal,
        PressureUnit.millimetreMercury => hectopascal * 0.750062,
      };
}
