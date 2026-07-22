import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../native_ad_manager.dart';

/// Renders a cached Native Advanced ad for [slotKey], styled as a rounded
/// card matching the app's list items. Collapses to nothing while
/// loading/failed so surrounding lists never show a placeholder gap.
class NativeAdCard extends StatefulWidget {
  final String slotKey;
  final double height;

  const NativeAdCard({super.key, required this.slotKey, this.height = 120});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  @override
  void initState() {
    super.initState();
    NativeAdManager.instance.addListener(_onAdsChanged);
    NativeAdManager.instance.ensureLoaded(widget.slotKey);
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: widget.height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: ad),
    );
  }
}
