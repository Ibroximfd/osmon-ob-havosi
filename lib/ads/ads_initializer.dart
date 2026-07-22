import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_consent_manager.dart';
import 'app_open_ad_manager.dart';
import 'interstitial_ad_manager.dart';

/// Orchestrates ad SDK startup: gather UMP consent, apply test-device
/// config, initialize the Mobile Ads SDK, then preload the first App Open
/// and Interstitial ads. Call once from main() without awaiting — nothing
/// here may block app startup or crash the app.
class AdsInitializer {
  AdsInitializer._();
  static final AdsInitializer instance = AdsInitializer._();

  Future<void> initialize() async {
    try {
      await AdConsentManager.instance.gatherConsent();

      if (AdConfig.testMode && AdConfig.testDeviceIds.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
        );
      }

      await MobileAds.instance.initialize();

      if (!await AdConsentManager.instance.canRequestAds) {
        debugPrint('AdsInitializer: ads not permitted yet (consent pending)');
        return;
      }

      unawaited(AppOpenAdManager.instance.loadAd());
      unawaited(InterstitialAdManager.instance.loadAd());
    } catch (e) {
      debugPrint('AdsInitializer: initialize failed: $e');
    }
  }
}
