import 'package:logger/logger.dart';
import '../../domain/entities/weather.dart';
import '../../core/utils/weather_condition_parser.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.temp,
    required super.condition,
    required super.city,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.aqi,
    required super.pressure,
    required super.isDay,
    required super.hourly,
    required super.daily,
  });

  static final _log = Logger();

  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String cityName, [
    int aqiValue = 0,
  ]) {
    final current = json['current'];
    final hourlyData = json['hourly'];
    final dailyData = json['daily'];

    // --- 24 soatlik prognoz (hozirgi soatdan boshlab) ---
    final hourlyList = <HourlyForecast>[];
    if (hourlyData != null) {
      final times = hourlyData['time'] as List;
      final now = DateTime.now();

      // Hozirgi soatga mos keladigan indeksni topamiz
      int startIndex = 0;
      for (int i = 0; i < times.length; i++) {
        final t = DateTime.parse(times[i] as String);
        if (t.year == now.year &&
            t.month == now.month &&
            t.day == now.day &&
            t.hour == now.hour) {
          startIndex = i;
          break;
        }
      }

      _log.i(
        'Hourly startIndex: $startIndex (hozir: ${now.hour}:00, jami: ${times.length} ta)',
      );

      int count = 0;
      for (int i = startIndex; i < times.length && count < 24; i++, count++) {
        final date = DateTime.parse(times[i] as String);
        final timeDisplay = count == 0 ? 'Hozir' : '${date.hour}:00';

        hourlyList.add(
          HourlyForecast(
            time: timeDisplay,
            temp: (hourlyData['temperature_2m'][i] as num).round(),
            code: hourlyData['weather_code'][i] as int,
          ),
        );
      }

      _log.d(
        'Hourly (birinchi 3): ${hourlyList.take(3).map((e) => '${e.time}:${e.temp}°').toList()}',
      );
    } else {
      _log.w('Hourly data null keldi!');
    }

    // --- 7 kunlik prognoz ---
    final dailyList = <DailyForecast>[];
    if (dailyData != null) {
      _log.i('Daily data — ${(dailyData["time"] as List).length} ta kun');
      const daysOfWeek = [
        'Dushanba',
        'Seshanba',
        'Chorshanba',
        'Payshanba',
        'Juma',
        'Shanba',
        'Yakshanba',
      ];
      final dailyTimes = dailyData['time'] as List;
      for (var i = 0; i < 7 && i < dailyTimes.length; i++) {
        final date = DateTime.parse(dailyTimes[i] as String);
        final dayDisplay = i == 0 ? 'Bugun' : daysOfWeek[date.weekday - 1];

        dailyList.add(
          DailyForecast(
            day: dayDisplay,
            min: (dailyData['temperature_2m_min'][i] as num).round(),
            max: (dailyData['temperature_2m_max'][i] as num).round(),
            code: dailyData['weather_code'][i] as int,
          ),
        );
      }
      _log.d(
        'Daily: ${dailyList.map((e) => '${e.day}: ${e.min}°-${e.max}°').toList()}',
      );
    } else {
      _log.w('Daily data null keldi!');
    }

    final currentCode = current['weather_code'] as int;

    _log.i(
      'Model: $cityName ${(current["temperature_2m"] as num).round()}°C, AQI: $aqiValue',
    );

    return WeatherModel(
      temp: (current['temperature_2m'] as num).round(),
      condition: WeatherConditionParser.getWeatherCondition(currentCode),
      city: cityName,
      feelsLike: (current['apparent_temperature'] as num).round(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      aqi: aqiValue,
      pressure: (current['surface_pressure'] as num).round(),
      isDay: current['is_day'] == 1,
      hourly: hourlyList,
      daily: dailyList,
    );
  }
}
