import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/place.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/weather/data/models/forecast_mapper.dart';

void main() {
  // A real Open-Meteo response for Tashkent, captured 2026-10-12 15:45.
  final json =
      jsonDecode(
            File('test/fixtures/forecast_tashkent.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final now = DateTime.utc(2026, 10, 12, 15, 45);

  final forecast = mapForecast(
    json: json,
    airJson: null,
    place: UzbekCities.tashkent,
    nowAt: (_) => now,
  );

  test('hourly starts at the current hour', () {
    expect(forecast.hourly.first.time, DateTime.utc(2026, 10, 12, 15));
  });

  test('the past 24 hours become the pressure history', () {
    expect(forecast.pressureHistory, hasLength(25));
    expect(forecast.pressureHistory.last.time, DateTime.utc(2026, 10, 12, 15));
  });

  test('ten days, sun times and the three-hour nowcast are read', () {
    expect(forecast.daily, hasLength(10));
    expect(forecast.daily.first.sunrise.hour, 6);
    expect(forecast.nowcast, hasLength(12));
    expect(forecast.utcOffsetSeconds, 18000);
    expect(forecast.place.timezoneId, 'Asia/Tashkent');
  });

  test('a cached payload re-anchors to a later now', () {
    final later = mapForecast(
      json: json,
      airJson: null,
      place: UzbekCities.tashkent,
      nowAt: (_) => now.add(const Duration(hours: 5)),
    );
    expect(later.hourly.first.time, DateTime.utc(2026, 10, 12, 20));
  });

  test('a missing block is a format error, not a crash', () {
    final broken = Map<String, dynamic>.of(json)..remove('daily');
    expect(
      () => mapForecast(
        json: broken,
        airJson: null,
        place: UzbekCities.tashkent,
        nowAt: (_) => now,
      ),
      throwsFormatException,
    );
  });
}
