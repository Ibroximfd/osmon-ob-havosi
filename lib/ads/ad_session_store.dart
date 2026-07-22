import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed state for ad frequency/session rules.
/// All ad managers should go through this instead of touching prefs directly.
class AdSessionStore {
  AdSessionStore._();
  static final AdSessionStore instance = AdSessionStore._();

  static const _kLaunchCount = 'ads_launch_count';
  static const _kAppOpenLastShownAt = 'ads_app_open_last_shown_at';
  static const _kInterstitialLastShownAt = 'ads_interstitial_last_shown_at';
  static const _kCitySwitchCount = 'ads_city_switch_count';

  SharedPreferences? _prefs;
  bool? _isFirstSessionCache;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// True for the whole lifetime of the process that first ever launched
  /// this install (a fresh install's whole first session, including
  /// backgrounding/resuming without being killed) — ads gated on this must
  /// never show. Latched in memory so it stays stable for this process
  /// even though the persisted launch counter is bumped on first read.
  Future<bool> isFirstSession() async {
    if (_isFirstSessionCache != null) return _isFirstSessionCache!;
    final prefs = await _p;
    final launchCount = prefs.getInt(_kLaunchCount) ?? 0;
    if (launchCount == 0) {
      await prefs.setInt(_kLaunchCount, 1);
      _isFirstSessionCache = true;
    } else {
      _isFirstSessionCache = false;
    }
    return _isFirstSessionCache!;
  }

  Future<bool> canShowAppOpenAd(Duration minInterval) async {
    if (await isFirstSession()) return false;
    final prefs = await _p;
    final lastShown = prefs.getInt(_kAppOpenLastShownAt);
    if (lastShown == null) return true;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastShown),
    );
    return elapsed >= minInterval;
  }

  Future<void> recordAppOpenShown() async {
    final prefs = await _p;
    await prefs.setInt(
      _kAppOpenLastShownAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<bool> canShowInterstitial({
    required Duration minInterval,
    required int citySwitchFrequency,
  }) async {
    if (await isFirstSession()) return false;
    final prefs = await _p;

    final lastShown = prefs.getInt(_kInterstitialLastShownAt);
    if (lastShown != null) {
      final elapsed = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastShown),
      );
      if (elapsed < minInterval) return false;
    }

    final switchCount = prefs.getInt(_kCitySwitchCount) ?? 0;
    return switchCount >= citySwitchFrequency;
  }

  Future<void> recordCitySwitch() async {
    final prefs = await _p;
    final count = prefs.getInt(_kCitySwitchCount) ?? 0;
    await prefs.setInt(_kCitySwitchCount, count + 1);
  }

  Future<void> recordInterstitialShown() async {
    final prefs = await _p;
    await prefs.setInt(
      _kInterstitialLastShownAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setInt(_kCitySwitchCount, 0);
  }
}
