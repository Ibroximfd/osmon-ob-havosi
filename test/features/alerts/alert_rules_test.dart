import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/weather_condition.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/bloc/load_status.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/domain/weather_alert.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/alerts/presentation/bloc/alerts_bloc.dart';

RegionDay _day({
  WeatherCondition condition = WeatherCondition.clear,
  double max = 30,
  double min = 15,
  double rain = 0,
  double snow = 0,
  double gusts = 20,
  double? dust,
}) => RegionDay(
  date: DateTime.utc(2026, 7, 1),
  condition: condition,
  maxTemperature: max,
  minTemperature: min,
  precipitationSum: rain,
  snowfallSum: snow,
  windGustsMax: gusts,
  dustMax: dust,
);

void main() {
  final place = UzbekCities.tashkent;

  test('an ordinary summer day raises nothing', () {
    expect(alertsFor(place, _day(max: 38)), isEmpty);
  });

  test('44 °C is an orange heat alert', () {
    final alerts = alertsFor(place, _day(max: 44));
    expect(alerts.single.kind, AlertKind.heat);
    expect(alerts.single.level, AlertLevel.orange);
  });

  test('hail is always red', () {
    final alerts = alertsFor(
      place,
      _day(condition: WeatherCondition.thunderstormHail, rain: 5),
    );
    expect(alerts.single.kind, AlertKind.hail);
    expect(alerts.single.level, AlertLevel.red);
  });

  test('frost is graded by how far below zero', () {
    final alerts = alertsFor(place, _day(min: -16, max: -5));
    expect(alerts.single.kind, AlertKind.frost);
    expect(alerts.single.level, AlertLevel.orange);
  });

  test('dust and wind can both fire on one day', () {
    final kinds = alertsFor(
      place,
      _day(gusts: 75, dust: 450),
    ).map((a) => a.kind);
    expect(kinds, containsAll(<AlertKind>[AlertKind.wind, AlertKind.dust]));
  });

  test("the user's own alerts are not repeated in the regional list", () {
    final tashkentRain = alertsFor(place, _day(rain: 20)).single;
    final nukus = UzbekCities.regionalCentres.last;
    final nukusHeat = alertsFor(nukus, _day(max: 44)).single;
    final state = AlertsState(
      status: LoadStatus.ready,
      alerts: <WeatherAlert>[tashkentRain, nukusHeat],
      ownPlace: place,
    );
    expect(state.ownAlerts, <WeatherAlert>[tashkentRain]);
    expect(state.regionAlerts, <WeatherAlert>[nukusHeat]);
  });
}
