import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_config.dart';
import '../ad_consent_manager.dart';

/// Anchored Adaptive Banner shown at the bottom of the main tabs.
/// Renders nothing (SizedBox.shrink) while loading or on failure — never a
/// placeholder box, so it can't visually break the layout it sits in.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    try {
      if (!await AdConsentManager.instance.canRequestAds) return;
      if (!mounted) return;

      final width = MediaQuery.of(context).size.width.truncate();
      final size = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        width,
      );
      if (size == null || !mounted) return;

      _bannerAd = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        request: const AdRequest(),
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('BannerAdWidget: loaded');
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() => _isLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAdWidget: failed to load: $error');
            ad.dispose();
          },
        ),
      );
      await _bannerAd!.load();
    } catch (e) {
      debugPrint('BannerAdWidget: load threw: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
