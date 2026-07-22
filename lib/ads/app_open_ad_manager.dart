import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_consent_manager.dart';
import 'ad_session_store.dart';
import 'ads_state.dart';

/// Singleton App Open ad manager. Only ever shown on
/// AppLifecycleState.resumed (see app_lifecycle_reactor.dart) — never on
/// cold start, never alongside another full-screen ad, never more often
/// than AdConfig.appOpenMinInterval.
class AppOpenAdManager {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  AppOpenAd? _ad;
  bool _isLoading = false;
  DateTime? _loadTime;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  bool get isAdAvailable {
    if (_ad == null || _loadTime == null) return false;
    final expired =
        DateTime.now().difference(_loadTime!) > AdConfig.appOpenMaxCacheDuration;
    if (expired) {
      _disposeAd();
      return false;
    }
    return true;
  }

  Future<void> loadAd() async {
    if (_isLoading || isAdAvailable) return;

    try {
      if (!await AdConsentManager.instance.canRequestAds) return;
    } catch (e) {
      debugPrint('AppOpenAdManager: consent check failed: $e');
      return;
    }

    _isLoading = true;
    try {
      await AppOpenAd.load(
        adUnitId: AdConfig.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AppOpenAdManager: loaded');
            _retryAttempt = 0;
            _isLoading = false;
            _ad = ad;
            _loadTime = DateTime.now();
          },
          onAdFailedToLoad: (error) {
            debugPrint('AppOpenAdManager: failed to load: $error');
            _isLoading = false;
            _scheduleRetry();
          },
        ),
      );
    } catch (e) {
      debugPrint('AppOpenAdManager: load threw: $e');
      _isLoading = false;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retryAttempt >= AdConfig.maxRetryAttempts) return;
    final delay = AdConfig.retryBackoff[_retryAttempt.clamp(
      0,
      AdConfig.retryBackoff.length - 1,
    )];
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, loadAd);
  }

  /// Shows the ad if one is ready and all frequency/coordination rules
  /// allow it. Safe to call unconditionally on every foreground event.
  Future<void> showAdIfAvailable() async {
    try {
      if (AdsState.isFullScreenAdShowing) {
        debugPrint('AppOpenAdManager: another full-screen ad is showing');
        return;
      }
      if (!isAdAvailable) {
        debugPrint('AppOpenAdManager: no ad ready, preloading for next time');
        loadAd();
        return;
      }
      if (!await AdSessionStore.instance.canShowAppOpenAd(
        AdConfig.appOpenMinInterval,
      )) {
        debugPrint('AppOpenAdManager: skipped by frequency cap/first session');
        return;
      }

      final ad = _ad!;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AdsState.isFullScreenAdShowing = true;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('AppOpenAdManager: failed to show: $error');
          AdsState.isFullScreenAdShowing = false;
          _disposeAd();
          loadAd();
        },
        onAdDismissedFullScreenContent: (ad) {
          AdsState.isFullScreenAdShowing = false;
          AdSessionStore.instance.recordAppOpenShown();
          _disposeAd();
          loadAd();
        },
      );
      await ad.show();
    } catch (e) {
      debugPrint('AppOpenAdManager: showAdIfAvailable threw: $e');
      AdsState.isFullScreenAdShowing = false;
    }
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    _loadTime = null;
  }

  void dispose() {
    _retryTimer?.cancel();
    _disposeAd();
  }
}
