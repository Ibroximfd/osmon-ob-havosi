import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/platform/external_flow.dart';
import 'ad_config.dart';
import 'ad_consent_manager.dart';

enum NativeAdSlotState { loading, loaded, failed }

/// Singleton pool of Native Advanced ads keyed by a caller-chosen "slot" id
/// (e.g. 'home_mid', 'prayer_end'). A slot is cached while its widget stays
/// mounted — scrolling never reloads it — and refreshed on a later visit
/// once the ad is old or the last request found no fill (see [ensureLoaded]).
/// Listeners are notified when a slot's state changes.
class NativeAdManager extends ChangeNotifier {
  NativeAdManager._();
  static final NativeAdManager instance = NativeAdManager._();

  final Map<String, NativeAd> _ads = {};
  final Map<String, NativeAdSlotState> _states = {};
  final Map<String, DateTime> _settledAt = {};

  NativeAd? adFor(String slotKey) => _ads[slotKey];

  NativeAdSlotState stateFor(String slotKey) =>
      _states[slotKey] ?? NativeAdSlotState.loading;

  /// Call when a slot's widget mounts. Loads the slot the first time, and
  /// again on a later visit once its ad is [AdConfig.nativeRefreshAfter]
  /// old (a new impression) or its last request found no fill (fill comes
  /// and goes). [adLabel] is the localized attribution badge ("Reklama",
  /// "Реклама", "Ad"…) — AdMob requires one on every native ad.
  Future<void> ensureLoaded(String slotKey, {required String adLabel}) async {
    if (!_needsLoad(slotKey)) return;
    _ads.remove(slotKey)?.dispose();
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
            _settledAt[slotKey] = DateTime.now();
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('NativeAdManager: failed to load slot $slotKey: $error');
            ad.dispose();
            _states[slotKey] = NativeAdSlotState.failed;
            _settledAt[slotKey] = DateTime.now();
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

  bool _needsLoad(String slotKey) {
    final state = _states[slotKey];
    if (state == null) return true;
    if (state == NativeAdSlotState.loading) return false;
    final settled = _settledAt[slotKey];
    return settled == null ||
        DateTime.now().difference(settled) >= AdConfig.nativeRefreshAfter;
  }

  void disposeAll() {
    for (final ad in _ads.values) {
      ad.dispose();
    }
    _ads.clear();
    _states.clear();
  }
}
