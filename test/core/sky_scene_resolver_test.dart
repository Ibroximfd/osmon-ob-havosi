import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/domain/weather_condition.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_scene.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/sky/sky_scene_resolver.dart';

void main() {
  test('storm outranks dust and rain', () {
    expect(
      resolveSkyScene(
        condition: WeatherCondition.thunderstorm,
        isDay: true,
        dustConcentration: 500,
      ),
      SkyScene.storm,
    );
  });

  test('heavy dust turns a clear day into a dust storm', () {
    expect(
      resolveSkyScene(
        condition: WeatherCondition.clear,
        isDay: true,
        dustConcentration: 200,
      ),
      SkyScene.dust,
    );
  });

  test('a clear sky near sunset is twilight', () {
    expect(
      resolveSkyScene(
        condition: WeatherCondition.clear,
        isDay: true,
        minutesToNearestSunEvent: -20,
      ),
      SkyScene.twilight,
    );
  });

  test('clouds at night use the night palette', () {
    expect(
      resolveSkyScene(condition: WeatherCondition.overcast, isDay: false),
      SkyScene.cloudyNight,
    );
  });
}
