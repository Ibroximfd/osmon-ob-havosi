import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/platform/external_flow.dart';
import 'ad_config.dart';
import 'ad_consent_manager.dart';

enum NativeAdSlotState { loading, loaded, failed }

/// Singleton pool of Native Advanced ads keyed by a caller-chosen "slot" id
/// (e.g. 'forecast_daily_0', 'home_hourly_1'). Each slot loads once and is
/// cached — list scrolling never triggers a reload — and notifies listeners
/// when its state changes so widgets can rebuild.
class NativeAdManager extends ChangeNotifier {
  NativeAdManager._();
  static final NativeAdManager instance = NativeAdManager._();

  final Map<String, NativeAd> _ads = {};
  final Map<String, NativeAdSlotState> _states = {};

  NativeAd? adFor(String slotKey) => _ads[slotKey];

  NativeAdSlotState stateFor(String slotKey) =>
      _states[slotKey] ?? NativeAdSlotState.loading;

  /// Idempotent — safe to call every time a slot's widget is built.
  /// [adLabel] is the localized attribution badge ("Reklama", "Реклама",
  /// "Ad"…) — AdMob requires one on every native ad.
  Future<void> ensureLoaded(String slotKey, {required String adLabel}) async {
    if (_states.containsKey(slotKey)) return;
    _states[slotKey] = NativeAdSlotState.loading;
    if (!AdConfig.isServable(AdConfig.nativeAdUnitId)) {
      _states[slotKey] = NativeAdSlotState.failed;
      return;
    }

    try {
      if (!await AdConsentManager.instance.canRequestAds) {
        _states[slotKey] = NativeAdSlotState.failed;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('NativeAdManager: consent check failed: $e');
      _states[slotKey] = NativeAdSlotState.failed;
      notifyListeners();
      return;
    }

    try {
      final ad = NativeAd(
        adUnitId: AdConfig.nativeAdUnitId,
        factoryId: AdConfig.nativeAdFactoryId,
        request: const AdRequest(),
        customOptions: <String, Object>{'adLabel': adLabel},
        // The card keeps its top-right corner clear for the AdChoices icon.
        nativeAdOptions: NativeAdOptions(
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        ),
        listener: NativeAdListener(
          onAdClicked: (ad) => ExternalFlow.markLeaving(),
          onAdLoaded: (ad) {
            debugPrint('NativeAdManager: loaded slot $slotKey');
            _ads[slotKey] = ad as NativeAd;
            _states[slotKey] = NativeAdSlotState.loaded;
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('NativeAdManager: failed to load slot $slotKey: $error');
            ad.dispose();
            _states[slotKey] = NativeAdSlotState.failed;
            notifyListeners();
          },
        ),
      );
      await ad.load();
    } catch (e) {
      debugPrint('NativeAdManager: load threw for slot $slotKey: $e');
      _states[slotKey] = NativeAdSlotState.failed;
      notifyListeners();
    }
  }

  void disposeAll() {
    for (final ad in _ads.values) {
      ad.dispose();
    }
    _ads.clear();
    _states.clear();
  }
}
