import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/l10n/l10n.dart';
import '../../core/platform/external_flow.dart';
import '../../core/theme/osmon_colors.dart';
import '../../core/theme/osmon_spacing.dart';
import '../../core/theme/osmon_typography.dart';
import '../ad_config.dart';
import '../ad_consent_manager.dart';

/// An inline adaptive banner placed *inside* scrolling content, labelled and
/// padded away from tappable cards. AdMob forbids banners pinned next to a
/// tab bar or wedged between content and a bottom menu, which is why the
/// app has no anchored banner. Renders nothing until an ad has loaded.
class InlineBannerAd extends StatefulWidget {
  const InlineBannerAd({super.key});

  @override
  State<InlineBannerAd> createState() => _InlineBannerAdState();
}

class _InlineBannerAdState extends State<InlineBannerAd> {
  BannerAd? _ad;
  AdSize? _size;
  bool _requested = false;

  /// Keeps the banner short so it never dominates the screen.
  static const int _maxHeight = 120;

  Future<void> _load(double width) async {
    _requested = true;
    if (!AdConfig.isServable(AdConfig.bannerAdUnitId)) return;
    if (!await AdConsentManager.instance.canRequestAds) return;
    final size = AdSize.getInlineAdaptiveBannerAdSize(
      width.truncate(),
      _maxHeight,
    );
    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (loaded) async {
          final banner = loaded as BannerAd;
          final platformSize = await banner.getPlatformAdSize();
          if (!mounted || platformSize == null) {
            await banner.dispose();
            return;
          }
          setState(() {
            _ad = banner;
            _size = platformSize;
          });
        },
        onAdFailedToLoad: (failed, error) => failed.dispose(),
        onAdClicked: (_) => ExternalFlow.markLeaving(),
      ),
    );
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (!_requested && constraints.maxWidth.isFinite) {
        _load(constraints.maxWidth);
      }
      final ad = _ad;
      final size = _size;
      if (ad == null || size == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.l10n.adLabel.toUpperCase(), style: OsmonType.eyebrow),
            const SizedBox(height: OsmonSpace.s6),
            Container(
              width: size.width.toDouble(),
              height: size.height.toDouble(),
              decoration: BoxDecoration(
                color: OsmonColors.glassFill,
                borderRadius: BorderRadius.circular(OsmonRadius.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: AdWidget(ad: ad),
            ),
          ],
        ),
      );
    },
  );
}
