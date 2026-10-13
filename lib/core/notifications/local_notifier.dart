import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;
import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/domain/notification_permissions.dart';
import '../platform/external_flow.dart';
import '../theme/osmon_colors.dart';

/// Android freezes a channel's sound and vibration once it exists on a
/// phone, so the Osmon chime lives in `_v2` channels and the 2.0.x ones are
/// removed (see [legacyIds]).
enum NotificationChannel {
  daily('osmon_daily_v2', 'Daily forecast', Importance.defaultImportance),
  alerts('osmon_alerts_v2', 'Weather alerts', Importance.high),
  prayer('osmon_prayer_v2', 'Prayer times', Importance.defaultImportance),

  /// Announcements pushed from the Firebase console; also the channel the
  /// manifest names for system-shown pushes.
  news('osmon_news_v2', 'News', Importance.high);

  const NotificationChannel(this.id, this.title, this.importance);

  final String id;

  /// System-settings label; Android shows it as written.
  final String title;
  final Importance importance;

  static const List<String> legacyIds = <String>[
    'osmon_daily',
    'osmon_alerts',
    'osmon_prayer',
    'osmon_news',
  ];
}

/// Thin wrapper over flutter_local_notifications. Scheduling takes UTC
/// instants so it never depends on the device's IANA zone name.
final class LocalNotifier implements NotificationPermissions {
  LocalNotifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// The app's own soft two-note chime (res/raw/osmon_chime.wav, generated
  /// by tool/sound/make_chime.py), so users know it is Osmon.
  static const AndroidNotificationSound _chime =
      RawResourceAndroidNotificationSound('osmon_chime');

  /// Two short, gentle pulses: noticeable in a pocket, never startling.
  static final Int64List _vibration = Int64List.fromList(<int>[
    0,
    160,
    110,
    160,
  ]);

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
    await _prepareChannels();
    _ready = true;
  }

  /// Creates every channel up front, so pushes the system shows (FCM, or a
  /// schedule firing before the app ran) already ring with the chime.
  Future<void> _prepareChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    for (final id in NotificationChannel.legacyIds) {
      await android.deleteNotificationChannel(id);
    }
    for (final channel in NotificationChannel.values) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id,
          channel.title,
          importance: channel.importance,
          sound: _chime,
          vibrationPattern: _vibration,
        ),
      );
    }
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
  Future<bool> isGranted() async {
    try {
      await initialize();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final options = await ios?.checkPermissions();
      return options?.isEnabled ?? false;
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
      sound: _chime,
      vibrationPattern: _vibration,
      styleInformation: BigTextStyleInformation(body),
      color: OsmonColors.accent,
    ),
    iOS: const DarwinNotificationDetails(presentSound: true),
  );
}
