import 'dart:io';

/// Centralized AdMob configuration: ad unit IDs and all frequency/timing
/// constants. Change values here, not in individual managers.
class AdConfig {
  AdConfig._();

  // ─────────────────────────────────────────────────────────────────
  // RELEASE CHECKLIST: set this to false before every release build.
  // Shipping with testMode=true serves no ads (no revenue); shipping
  // debug/test IDs with testMode=false risks an AdMob account suspension.
  // ─────────────────────────────────────────────────────────────────
  static const bool testMode = false;

  /// factoryId shared between Dart's NativeAd(factoryId: ...) calls and the
  /// platform-side NativeAdFactory registered in MainActivity.kt / AppDelegate.swift.
  static const String nativeAdFactoryId = 'listTile';

  // ── App Open ───────────────────────────────────────────────────
  static String get appOpenAdUnitId {
    if (testMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-3940256099942544/9257395921';
    }
    // ca-app-pub-9217530480544704 / "full"
    return 'ca-app-pub-9217530480544704/5347366148';
  }

  // ── Banner ─────────────────────────────────────────────────────
  static String get bannerAdUnitId {
    if (testMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111';
    }
    // ca-app-pub-9217530480544704 / "har doim"
    return 'ca-app-pub-9217530480544704/7074692424';
  }

  // ── Interstitial ───────────────────────────────────────────────
  // NOTE: no production ad unit exists yet — the doc's "Interstitial" unit
  // has "Partner bidding" enabled and can't be used with a plain AdMob
  // request. Create a NEW non-bidding Interstitial unit in AdMob console
  // and replace the string below before release.
  static String get interstitialAdUnitId {
    if (testMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    // TODO: replace with the real non-bidding Interstitial ad unit ID.
    return Platform.isIOS
        ? 'ca-app-pub-3940256099942544/4411468910'
        : 'ca-app-pub-3940256099942544/1033173712';
  }

  // ── Native Advanced ────────────────────────────────────────────
  // NOTE: same as Interstitial — the doc's "Native advanced" unit has
  // "Partner bidding" enabled. Create a NEW non-bidding Native Advanced
  // unit in AdMob console and replace the string below before release.
  static String get nativeAdUnitId {
    if (testMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-3940256099942544/2247696110';
    }
    // TODO: replace with the real non-bidding Native Advanced ad unit ID.
    return Platform.isIOS
        ? 'ca-app-pub-3940256099942544/3986624511'
        : 'ca-app-pub-3940256099942544/2247696110';
  }

  /// Add your test device's advertising ID here while testMode is false,
  /// so you can preview production ads on your own device without risking
  /// invalid-traffic flags on your AdMob account.
  static const List<String> testDeviceIds = [];

  // ── App Open rules ─────────────────────────────────────────────
  static const Duration appOpenMinInterval = Duration(hours: 4);
  static const Duration appOpenLoadTimeout = Duration(seconds: 4);
  static const Duration appOpenMaxCacheDuration = Duration(hours: 4);

  // ── Interstitial rules ──────────────────────────────────────────
  static const Duration interstitialMinInterval = Duration(minutes: 3);
  static const int interstitialCitySwitchFrequency = 3;

  // ── Native rules ────────────────────────────────────────────────
  static const int nativeAdEveryNItems = 5;

  // ── Retry / backoff (shared by App Open, Interstitial, Native, Banner) ──
  static const int maxRetryAttempts = 5;
  static const List<Duration> retryBackoff = [
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 4),
    Duration(minutes: 8),
    Duration(minutes: 16),
  ];
}
