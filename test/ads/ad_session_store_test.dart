import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/ads/ad_config.dart';
import 'package:osmon_uzbekiston_ob_havosi/ads/ad_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  var now = DateTime(2026, 10, 13, 12);
  DateTime clock() => now;

  Future<bool> transition(AdSessionStore store) =>
      store.recordTransitionAndCheck(
        minInterval: AdConfig.interstitialMinInterval,
        frequency: AdConfig.interstitialTransitionFrequency,
        dailyCap: AdConfig.interstitialDailyCap,
        afterAppOpen: AdConfig.interstitialAfterAppOpen,
        installGrace: AdConfig.interstitialInstallGrace,
      );

  /// An install that first launched [age] ago, now on a later launch.
  AdSessionStore installedFor(Duration age) {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'ads_launch_count': 1,
      'ads_first_launch_at': now.subtract(age).millisecondsSinceEpoch,
    });
    return AdSessionStore(now: clock);
  }

  setUp(() => now = DateTime(2026, 10, 13, 12));

  test(
    'a fresh install never sees an interstitial in its first session',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = AdSessionStore(now: clock);
      for (var i = 0; i < 5; i++) {
        expect(await transition(store), isFalse);
      }
    },
  );

  test('nothing during the first day, even on the third transition', () async {
    final store = installedFor(const Duration(hours: 5));
    expect(await transition(store), isFalse);
    expect(await transition(store), isFalse);
    expect(await transition(store), isFalse);
  });

  test('after the first day, only every third transition may show', () async {
    final store = installedFor(const Duration(days: 3));
    expect(await transition(store), isFalse);
    expect(await transition(store), isFalse);
    expect(await transition(store), isTrue);
  });

  test('a shown ad resets the count and enforces the interval', () async {
    final store = installedFor(const Duration(days: 3));
    await store.recordInterstitialShown();
    for (var i = 0; i < 3; i++) {
      await transition(store);
    }
    now = now.add(const Duration(minutes: 1));
    expect(await transition(store), isFalse, reason: 'too soon');
    now = now.add(AdConfig.interstitialMinInterval);
    expect(await transition(store), isTrue);
  });

  test('the daily cap holds until the next day', () async {
    final store = installedFor(const Duration(days: 3));
    for (var shown = 0; shown < AdConfig.interstitialDailyCap; shown++) {
      await store.recordInterstitialShown();
    }
    now = now.add(AdConfig.interstitialMinInterval);
    for (var i = 0; i < 3; i++) {
      expect(await transition(store), isFalse);
    }
    now = DateTime(2026, 10, 14, 9);
    expect(await transition(store), isTrue);
  });

  test('no interstitial right after an app-open ad', () async {
    final store = installedFor(const Duration(days: 3));
    await store.recordAppOpenShown();
    await transition(store);
    await transition(store);
    expect(await transition(store), isFalse);
    now = now.add(AdConfig.interstitialAfterAppOpen);
    expect(await transition(store), isTrue);
  });
}
