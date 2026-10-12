import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/platform/external_flow.dart';
import 'ad_config.dart';
import 'ad_consent_manager.dart';
import 'ad_session_store.dart';
import 'ads_state.dart';

/// Singleton Interstitial ad manager. Only shown from natural pause points
/// (city switch) — never on cold start or during a critical action like a
/// permission prompt. Frequency-capped by both a minimum time interval and
/// a minimum number of city switches, and never shown in the first session.
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _ad;
  bool _isLoading = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  bool get isAdAvailable => _ad != null;

  Future<void> loadAd() async {
    if (_isLoading || isAdAvailable) return;
    if (!AdConfig.isServable(AdConfig.interstitialAdUnitId)) return;

    try {
      if (!await AdConsentManager.instance.canRequestAds) return;
    } catch (e) {
      debugPrint('InterstitialAdManager: consent check failed: $e');
      return;
    }

    _isLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: AdConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('InterstitialAdManager: loaded');
            _retryAttempt = 0;
            _isLoading = false;
            _ad = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('InterstitialAdManager: failed to load: $error');
            _isLoading = false;
            _scheduleRetry();
          },
        ),
      );
    } catch (e) {
      debugPrint('InterstitialAdManager: load threw: $e');
      _isLoading = false;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retryAttempt >= AdConfig.maxRetryAttempts) return;
    final delay = AdConfig
        .retryBackoff[_retryAttempt.clamp(0, AdConfig.retryBackoff.length - 1)];
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, loadAd);
  }

  /// Call from the city-switch flow (search_page.dart). Fire-and-forget —
  /// silently no-ops if any frequency/coordination rule blocks the show.
  Future<void> maybeShowOnCitySwitch() async {
    try {
      await AdSessionStore.instance.recordCitySwitch();

      if (AdsState.isFullScreenAdShowing) return;
      if (!isAdAvailable) {
        loadAd();
        return;
      }
      if (!await AdSessionStore.instance.canShowInterstitial(
        minInterval: AdConfig.interstitialMinInterval,
        citySwitchFrequency: AdConfig.interstitialCitySwitchFrequency,
      )) {
        return;
      }

      final ad = _ad!;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AdsState.isFullScreenAdShowing = true;
        },
        onAdClicked: (ad) => ExternalFlow.markLeaving(),
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('InterstitialAdManager: failed to show: $error');
          AdsState.isFullScreenAdShowing = false;
          _disposeAd();
          loadAd();
        },
        onAdDismissedFullScreenContent: (ad) {
          AdsState.isFullScreenAdShowing = false;
          AdSessionStore.instance.recordInterstitialShown();
          _disposeAd();
          loadAd();
        },
      );
      await ad.show();
    } catch (e) {
      debugPrint('InterstitialAdManager: maybeShowOnCitySwitch threw: $e');
      AdsState.isFullScreenAdShowing = false;
    }
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
  }

  void dispose() {
    _retryTimer?.cancel();
    _disposeAd();
  }
}
