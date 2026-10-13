import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/osmon_colors.dart';
import '../../core/theme/osmon_spacing.dart';
import '../../core/theme/osmon_typography.dart';
import 'banner_slot.dart';

/// An inline adaptive banner placed *inside* scrolling content, labelled and
/// padded away from tappable cards. AdMob forbids banners pinned next to a
/// tab bar or wedged between content and a bottom menu, so scrolling pages
/// use this one. Renders nothing until an ad has loaded.
class InlineBannerAd extends StatelessWidget {
  const InlineBannerAd({super.key});

  /// Keeps the banner short so it never dominates the screen.
  static const int _maxHeight = 120;

  @override
  Widget build(BuildContext context) => BannerSlot(
    sizeFor: (width) async =>
        AdSize.getInlineAdaptiveBannerAdSize(width, _maxHeight),
    builder: (context, ad, size) => Padding(
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
            child: ad,
          ),
        ],
      ),
    ),
  );
}
