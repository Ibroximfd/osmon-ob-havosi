import 'dart:io';

/// Centralized AdMob configuration: ad unit IDs and all frequency/timing
/// constants. Change values here, not in individual managers.
class AdConfig {
  AdConfig._();

  // ─────────────────────────────────────────────────────────────────
  // RELEASE CHECKLIST: set this to false before every release build.
  // Shipping with testMode=true serves only test ads (no revenue).
  // ─────────────────────────────────────────────────────────────────
  static const bool testMode = false;

  /// factoryId shared between Dart's NativeAd(factoryId: ...) calls and the
  /// platform-side NativeAdFactory registered in MainActivity.kt / AppDelegate.swift.
  static const String nativeAdFactoryId = 'listTile';

  /// Prefix of Google's public sample ad units.
  static const String _samplePublisher = 'ca-app-pub-3940256099942544';

  // ── Production units ────────────────────────────────────────────
  // AdMob account pub-2122406741205447, app "Ob havo uz" (Android,
  // ca-app-pub-2122406741205447~2535659455 — must match AndroidManifest).
  // Units must be "standard" serving type: partner-bidding units only serve
  // through third-party mediation and never fill direct SDK requests.
  // An empty string means "no unit created yet": that format stays off in
  // release builds instead of serving Google's sample ads to real users.
  static const String _appOpenAndroid =
      'ca-app-pub-2122406741205447/1483805692';
  static const String _bannerAndroid = 'ca-app-pub-2122406741205447/7857642355';
  static const String _interstitialAndroid =
      'ca-app-pub-2122406741205447/6544560687';
  static const String _nativeAndroid = 'ca-app-pub-2122406741205447/6359807984';
  static const String _appOpenIos = '';
  static const String _bannerIos = '';
  static const String _interstitialIos = '';
  static const String _nativeIos = '';

  static String get appOpenAdUnitId => _pick(
    android: _appOpenAndroid,
    ios: _appOpenIos,
    testAndroid: '$_samplePublisher/9257395921',
    testIos: '$_samplePublisher/5575463023',
  );

  static String get bannerAdUnitId => _pick(
    android: _bannerAndroid,
    ios: _bannerIos,
    testAndroid: '$_samplePublisher/9214589741',
    testIos: '$_samplePublisher/2435281174',
  );

  static String get interstitialAdUnitId => _pick(
    android: _interstitialAndroid,
    ios: _interstitialIos,
    testAndroid: '$_samplePublisher/1033173712',
    testIos: '$_samplePublisher/4411468910',
  );

  static String get nativeAdUnitId => _pick(
    android: _nativeAndroid,
    ios: _nativeIos,
    testAndroid: '$_samplePublisher/2247696110',
    testIos: '$_samplePublisher/3986624511',
  );

  static String _pick({
    required String android,
    required String ios,
    required String testAndroid,
    required String testIos,
  }) {
    if (testMode) return Platform.isIOS ? testIos : testAndroid;
    return Platform.isIOS ? ios : android;
  }

  /// False when the unit is missing — the manager then skips the request.
  static bool isServable(String adUnitId) =>
      adUnitId.isNotEmpty &&
      (testMode || !adUnitId.startsWith(_samplePublisher));

  /// Add your test device's advertising ID here while testMode is false,
  /// so you can preview production ads on your own device without risking
  /// invalid-traffic flags on your AdMob account.
  static const List<String> testDeviceIds = [];

  // ── App Open rules ─────────────────────────────────────────────
  static const Duration appOpenMinInterval = Duration(hours: 4);
  static const Duration appOpenMaxCacheDuration = Duration(hours: 4);

  // ── Interstitial rules ──────────────────────────────────────────
  // Interstitials only ever appear at a transition (switching city, opening
  // a feature page), and these caps keep them rare enough that nobody
  // leaves the app over them.
  static const Duration interstitialMinInterval = Duration(minutes: 4);

  /// Every n-th transition may show one.
  static const int interstitialTransitionFrequency = 3;
  static const int interstitialDailyCap = 4;

  /// Breathing room after an app-open ad.
  static const Duration interstitialAfterAppOpen = Duration(minutes: 2);

  /// A new install sees no interstitial during its first day.
  static const Duration interstitialInstallGrace = Duration(hours: 24);

  // ── Native rules ───────────────────────────────────────────────
  /// A page opened again after this long gets a fresh native ad (AdMob asks
  /// for at least 60 s between refreshes).
  static const Duration nativeRefreshAfter = Duration(seconds: 60);

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
