import 'package:equatable/equatable.dart';

enum PollenType { alder, birch, grass, mugwort, olive, ragweed }

final class AirReading extends Equatable {
  const AirReading({
    required this.time,
    this.usAqi,
    this.pm25,
    this.pm10,
    this.nitrogenDioxide,
    this.ozone,
    this.dust,
    this.pollen = const <PollenType, double>{},
  });

  final DateTime time;
  final double? usAqi;
  final double? pm25;
  final double? pm10;
  final double? nitrogenDioxide;
  final double? ozone;
  final double? dust;

  /// grains/m³ per type; only types the model actually reports.
  final Map<PollenType, double> pollen;

  @override
  List<Object?> get props => <Object?>[
    time,
    usAqi,
    pm25,
    pm10,
    nitrogenDioxide,
    ozone,
    dust,
    pollen,
  ];
}

final class AirQualityReport extends Equatable {
  const AirQualityReport({required this.current, required this.hourly});

  final AirReading current;

  /// Next three days, hourly.
  final List<AirReading> hourly;

  /// CAMS pollen is modelled for Europe only — elsewhere every value is
  /// null and the app falls back to the seasonal calendar.
  bool get hasMeasuredPollen =>
      current.pollen.isNotEmpty || hourly.any((h) => h.pollen.isNotEmpty);

  @override
  List<Object?> get props => <Object?>[current, hourly];
}
