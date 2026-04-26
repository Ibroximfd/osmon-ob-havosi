import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _permAskedKey = 'notif_perm_asked';

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_permAskedKey, true);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  static Future<bool> wasPermissionAsked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permAskedKey) ?? false;
  }

  static Future<void> scheduleDailyWeatherNotification({
    required String city,
    required int temp,
    required String condition,
  }) async {
    await _plugin.zonedSchedule(
      0,
      'Bugungi ob-havo: $city',
      '$condition, $temp°C. Yaxshi kun o\'tkazing!',
      _nextDailyAt(7, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_weather',
          'Kunlik ob-havo',
          channelDescription: 'Har kuni ertalab soat 07:00 da ob-havo xabari',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showRainAlert(String city) async {
    await _plugin.show(
      1,
      '🌧️ Yomg\'ir kelmoqda!',
      '$city da yomg\'ir kutilmoqda. Soyabonni unutmang!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rain_alert',
          'Yomg\'ir ogohlantirishlari',
          channelDescription: 'Yomg\'ir bo\'lganda ogohlantirish',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextDailyAt(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
