import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed state for ad frequency/session rules.
/// All ad managers should go through this instead of touching prefs directly.
class AdSessionStore {
  AdSessionStore({DateTime Function()? now}) : _now = now ?? DateTime.now;
  static final AdSessionStore instance = AdSessionStore();

  static const _kLaunchCount = 'ads_launch_count';
  static const _kFirstLaunchAt = 'ads_first_launch_at';
  static const _kAppOpenLastShownAt = 'ads_app_open_last_shown_at';
  static const _kInterstitialLastShownAt = 'ads_interstitial_last_shown_at';
  static const _kTransitionCount = 'ads_transition_count';
  static const _kInterstitialDay = 'ads_interstitial_day';
  static const _kInterstitialDayCount = 'ads_interstitial_day_count';

  final DateTime Function() _now;
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
      await prefs.setInt(_kFirstLaunchAt, _now().millisecondsSinceEpoch);
      _isFirstSessionCache = true;
    } else {
      _isFirstSessionCache = false;
    }
    return _isFirstSessionCache!;
  }

  Future<bool> canShowAppOpenAd(Duration minInterval) async {
    if (await isFirstSession()) return false;
    final prefs = await _p;
    return _elapsedSince(prefs, _kAppOpenLastShownAt) >= minInterval;
  }

  Future<void> recordAppOpenShown() async {
    final prefs = await _p;
    await prefs.setInt(_kAppOpenLastShownAt, _now().millisecondsSinceEpoch);
  }

  /// Counts a transition (city switch, feature page opened) and tells
  /// whether an interstitial may show on it.
  Future<bool> recordTransitionAndCheck({
    required Duration minInterval,
    required int frequency,
    required int dailyCap,
    required Duration afterAppOpen,
    required Duration installGrace,
  }) async {
    if (await isFirstSession()) return false;
    final prefs = await _p;
    final transitions = (prefs.getInt(_kTransitionCount) ?? 0) + 1;
    await prefs.setInt(_kTransitionCount, transitions);

    // Installs that predate this key are old users: no grace for them.
    final firstLaunch = prefs.getInt(_kFirstLaunchAt);
    if (firstLaunch != null &&
        _now().difference(DateTime.fromMillisecondsSinceEpoch(firstLaunch)) <
            installGrace) {
      return false;
    }
    if (transitions < frequency) return false;
    if (_elapsedSince(prefs, _kInterstitialLastShownAt) < minInterval) {
      return false;
    }
    if (_elapsedSince(prefs, _kAppOpenLastShownAt) < afterAppOpen) {
      return false;
    }
    return _shownToday(prefs) < dailyCap;
  }

  Future<void> recordInterstitialShown() async {
    final prefs = await _p;
    // Read before the day key moves, or yesterday's count would carry over.
    final shownToday = _shownToday(prefs) + 1;
    await prefs.setInt(
      _kInterstitialLastShownAt,
      _now().millisecondsSinceEpoch,
    );
    await prefs.setInt(_kTransitionCount, 0);
    await prefs.setString(_kInterstitialDay, _today());
    await prefs.setInt(_kInterstitialDayCount, shownToday);
  }

  int _shownToday(SharedPreferences prefs) =>
      prefs.getString(_kInterstitialDay) == _today()
      ? prefs.getInt(_kInterstitialDayCount) ?? 0
      : 0;

  String _today() {
    final now = _now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// "Forever" when the event never happened.
  Duration _elapsedSince(SharedPreferences prefs, String key) {
    final at = prefs.getInt(key);
    if (at == null) return const Duration(days: 365);
    return _now().difference(DateTime.fromMillisecondsSinceEpoch(at));
  }
}
