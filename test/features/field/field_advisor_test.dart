import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/domain/field_advisor.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/field/domain/field_conditions.dart';

final DateTime _now = DateTime.utc(2026, 4, 10, 8);

FieldDay _day(
  int offset, {
  double min = 8,
  double max = 20,
  double rain = 0,
  double chance = 0,
  double et0 = 4,
}) => FieldDay(
  date: DateTime.utc(2026, 4, 10).add(Duration(days: offset)),
  minTemperature: min,
  maxTemperature: max,
  precipitationSum: rain,
  precipitationProbability: chance,
  evapotranspiration: et0,
);

FieldHour _hour(
  int offset, {
  double wind = 5,
  double gust = 9,
  double chance = 0,
  bool day = true,
  double temp = 15,
}) => FieldHour(
  time: _now.add(Duration(hours: offset)),
  temperature: temp,
  windSpeed: wind,
  windGusts: gust,
  precipitationProbability: chance,
  isDay: day,
);

FieldConditions _conditions({
  List<FieldDay>? days,
  List<FieldHour>? hours,
  double moisture = 0.25,
  List<FieldDay> season = const <FieldDay>[],
}) => FieldConditions(
  now: _now,
  soilTemperatureSurface: 14,
  soilTemperatureRoot: 12,
  soilMoisture: moisture,
  hours: hours ?? <FieldHour>[for (var i = 0; i < 12; i++) _hour(i)],
  days: days ?? <FieldDay>[for (var i = 0; i < 7; i++) _day(i)],
  season: season,
);

void main() {
  group('frost', () {
    test('cotton seedlings are at risk at +1 °C', () {
      final outlook = frostOutlookFor(
        _conditions(days: <FieldDay>[_day(0), _day(1, min: 1), _day(2)]),
        Crop.cotton,
      )!;
      expect(outlook.risk, FrostRisk.likely);
      expect(outlook.coldest, 1);
    });

    test('wheat tolerates the same night', () {
      final outlook = frostOutlookFor(
        _conditions(days: <FieldDay>[_day(0), _day(1, min: 1), _day(2)]),
        Crop.wheat,
      )!;
      expect(outlook.risk, FrostRisk.none);
    });
  });

  group('irrigation', () {
    test(
      'dry soil and no rain means irrigate now, with volume per hectare',
      () {
        final advice = irrigationAdviceFor(
          _conditions(moisture: 0.12),
          Crop.cotton,
        );
        expect(advice.need, IrrigationNeed.now);
        // 3 days × 4 mm × Kc 1.15 = 13.8 mm → 138 m³/ha
        expect(advice.deficitMillimetres, closeTo(13.8, 0.01));
        expect(advice.cubicMetresPerHectare, closeTo(138, 0.1));
      },
    );

    test('expected rain covers the need', () {
      final advice = irrigationAdviceFor(
        _conditions(
          days: <FieldDay>[for (var i = 0; i < 3; i++) _day(i, rain: 10)],
        ),
        Crop.wheat,
      );
      expect(advice.need, IrrigationNeed.notNeeded);
    });
  });

  group('spray windows', () {
    test('calm dry daylight hours form one window', () {
      final windows = sprayWindowsFor(_conditions());
      expect(windows, isNotEmpty);
      expect(windows.first.start, _now);
    });

    test('wind breaks the window', () {
      final hours = <FieldHour>[
        for (var i = 0; i < 12; i++) _hour(i, wind: i == 3 ? 25 : 5),
      ];
      final windows = sprayWindowsFor(_conditions(hours: hours));
      expect(windows.first.end, _now.add(const Duration(hours: 3)));
    });

    test('nothing at night', () {
      final hours = <FieldHour>[
        for (var i = 0; i < 12; i++) _hour(i, day: false),
      ];
      expect(sprayWindowsFor(_conditions(hours: hours)), isEmpty);
    });
  });

  test('growing degree days sum the mean above the crop base', () {
    final season = <FieldDay>[
      _day(-2, min: 10, max: 20),
      _day(-1, min: 12, max: 24),
    ];
    // means 15 and 18; grape base 10 → 5 + 8
    expect(growingDegreeDays(_conditions(season: season), Crop.grape), 13);
    expect(growingDegreeDays(_conditions(), Crop.grape), isNull);
  });
}
