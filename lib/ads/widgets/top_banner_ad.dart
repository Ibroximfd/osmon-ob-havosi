import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/theme/osmon_colors.dart';
import '../../core/theme/osmon_spacing.dart';
import 'banner_slot.dart';

/// A banner in its own strip at the very top of a full-screen tool (the
/// map). It never overlays the content — the map starts below it — and it
/// sits far from the tab bar, where AdMob forbids anchored banners. The
/// strip also owns the status-bar area, painted whether or not an ad loads.
class TopBannerAd extends StatelessWidget {
  const TopBannerAd({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: OsmonColors.ink,
    child: Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: BannerSlot(
        sizeFor: AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize,
        builder: (context, ad, size) => DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: OsmonColors.glassStrokeSoft,
                width: OsmonSize.strokeHairline,
              ),
            ),
          ),
          child: Center(
            child: SizedBox(
              width: size.width.toDouble(),
              height: size.height.toDouble(),
              child: ad,
            ),
          ),
        ),
      ),
    ),
  );
}
