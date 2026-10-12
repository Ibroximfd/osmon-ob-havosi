import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/app/services/push_messaging.dart';

void main() {
  test('push topics match the names used in Firebase console campaigns', () {
    expect(PushMessaging.allTopic, 'all');
    expect(PushMessaging.languageTopic('uz'), 'lang_uz');
    expect(PushMessaging.languageTopic('ru'), 'lang_ru');
  });
}
