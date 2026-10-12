import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;
import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/domain/notification_permissions.dart';
import '../platform/external_flow.dart';
import '../theme/osmon_colors.dart';

enum NotificationChannel {
  daily('osmon_daily', 'Daily forecast', Importance.defaultImportance),
  alerts('osmon_alerts', 'Weather alerts', Importance.high),
  prayer('osmon_prayer', 'Prayer times', Importance.low),

  /// Announcements pushed from the Firebase console; also the channel the
  /// manifest names for system-shown pushes.
  news('osmon_news', 'News', Importance.high);

  const NotificationChannel(this.id, this.title, this.importance);

  final String id;

  /// System-settings label; Android shows it as written.
  final String title;
  final Importance importance;
}

/// Thin wrapper over flutter_local_notifications. Scheduling takes UTC
/// instants so it never depends on the device's IANA zone name.
final class LocalNotifier implements NotificationPermissions {
  LocalNotifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_osmon'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// A refusal and a platform error read the same to the caller: the toggle
  /// stays off and the user is pointed to the system settings. The plugin
  /// throws, for instance, while an earlier permission dialog is still open.
  @override
  Future<bool> request() async {
    try {
      return await _requestFromPlatform();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    // The user comes back whenever they like; keep the app-open ad away.
    ExternalFlow.markLeaving();
    await openAppSettings();
  }

  Future<bool> _requestFromPlatform() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  /// Channels are otherwise created on first use; a push shown by the
  /// system before that would land in a generic "Miscellaneous" channel.
  Future<void> ensureChannel(NotificationChannel channel) async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            channel.id,
            channel.title,
            importance: channel.importance,
          ),
        );
  }

  Future<void> show({
    required int id,
    required NotificationChannel channel,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _plugin.show(id, title, body, _details(channel, body));
  }

  Future<void> scheduleAt({
    required int id,
    required NotificationChannel channel,
    required String title,
    required String body,
    required DateTime utcInstant,
  }) async {
    await initialize();
    if (!utcInstant.isAfter(DateTime.now().toUtc())) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(utcInstant, tz.UTC),
      _details(channel, body),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelIds(Iterable<int> ids) async {
    await initialize();
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  static NotificationDetails _details(
    NotificationChannel channel,
    String body,
  ) => NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.title,
      importance: channel.importance,
      priority: channel.importance == Importance.high
          ? Priority.high
          : Priority.defaultPriority,
      playSound: channel != NotificationChannel.prayer,
      styleInformation: BigTextStyleInformation(body),
      color: OsmonColors.accent,
    ),
    iOS: DarwinNotificationDetails(
      presentSound: channel != NotificationChannel.prayer,
    ),
  );
}
