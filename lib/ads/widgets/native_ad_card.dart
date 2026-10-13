import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/osmon_colors.dart';
import '../../core/theme/osmon_spacing.dart';
import '../native_ad_manager.dart';

/// Renders a cached Native Advanced ad for [slotKey] on the same glass
/// surface as the cards around it. Collapses to nothing while loading or
/// failed so lists never show a placeholder gap.
class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key, required this.slotKey, this.height = 120});

  final String slotKey;
  final double height;

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

/// A native ad closing a page: the user has finished reading, so it
/// interrupts nothing and still gets seen.
class PageEndNativeAd extends StatelessWidget {
  const PageEndNativeAd({super.key, required this.slotKey});

  final String slotKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: OsmonSpace.s16),
    child: NativeAdCard(slotKey: slotKey),
  );
}

class _NativeAdCardState extends State<NativeAdCard> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    NativeAdManager.instance.addListener(_onAdsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    NativeAdManager.instance.ensureLoaded(
      widget.slotKey,
      adLabel: context.l10n.adLabel,
    );
  }

  @override
  void dispose() {
    NativeAdManager.instance.removeListener(_onAdsChanged);
    super.dispose();
  }

  void _onAdsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ad = NativeAdManager.instance.adFor(widget.slotKey);
    if (ad == null) return const SizedBox.shrink();
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: OsmonColors.glassFill,
        borderRadius: BorderRadius.circular(OsmonRadius.lg),
        border: Border.all(color: OsmonColors.glassStroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: ad),
    );
  }
}
