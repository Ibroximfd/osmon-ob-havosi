import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/notifications/local_notifier.dart';

/// Firebase Cloud Messaging. A console campaign reaches everyone through the
/// `all` topic, or one language through `lang_<code>`. In the background the
/// system shows the push; while the app is open Android stays silent, so it
/// is shown here through the news channel.
final class PushMessaging {
  PushMessaging(this._notifier);

  final LocalNotifier _notifier;
  StreamSubscription<RemoteMessage>? _foreground;
  String? _language;

  static const String allTopic = 'all';

  static String languageTopic(String code) => 'lang_$code';

  Future<void> start(String languageCode) async {
    // Creates the news channel the manifest names for system-shown pushes.
    await _notifier.initialize();
    _foreground ??= FirebaseMessaging.onMessage.listen(_showInApp);
    await _bestEffort(FirebaseMessaging.instance.subscribeToTopic(allTopic));
    await syncLanguage(languageCode);
  }

  /// Moves the device from the previous language's topic to [code].
  Future<void> syncLanguage(String code) async {
    if (code == _language) return;
    final previous = _language;
    _language = code;
    final messaging = FirebaseMessaging.instance;
    if (previous != null) {
      await _bestEffort(
        messaging.unsubscribeFromTopic(languageTopic(previous)),
      );
    }
    await _bestEffort(messaging.subscribeToTopic(languageTopic(code)));
  }

  Future<void> _showInApp(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _notifier.show(
      id: message.messageId.hashCode & 0x7fffffff,
      channel: NotificationChannel.news,
      title: notification.title ?? '',
      body: notification.body ?? '',
    );
  }

  /// Topic calls need the network. A failure only delays the subscription
  /// to the next start, so it must not surface as an app error.
  static Future<void> _bestEffort(Future<void> call) async {
    try {
      await call;
    } on FirebaseException {
      return;
    }
  }
}
