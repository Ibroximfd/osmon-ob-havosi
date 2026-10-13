import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/platform/external_flow.dart';
import '../ad_config.dart';
import '../ad_consent_manager.dart';

/// Loads and shows one banner while its tab is on screen. Banners refresh
/// themselves, and a tab kept alive offstage must not: AdMob would count
/// impressions nobody saw. So the ad is released when the tab goes
/// offstage and requested again on return. Renders nothing until loaded.
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key, required this.sizeFor, required this.builder});

  /// The banner size for the available width, in logical pixels.
  final Future<AdSize?> Function(int width) sizeFor;

  /// Frames the loaded [ad] widget at its platform [size].
  final Widget Function(BuildContext context, Widget ad, AdSize size) builder;

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _ad;
  AdSize? _size;
  double? _width;
  bool _visible = true;

  /// Bumped whenever a pending load must be ignored (tab left, disposed).
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible == _visible) return;
    _visible = visible;
    final width = _width;
    if (!visible) {
      _release();
    } else if (width != null) {
      _load(width);
    }
  }

  bool _isCurrent(int generation) =>
      mounted && _visible && generation == _generation;

  Future<void> _load(double width) async {
    final generation = ++_generation;
    if (!AdConfig.isServable(AdConfig.bannerAdUnitId)) return;
    if (!await AdConsentManager.instance.canRequestAds) return;
    final size = await widget.sizeFor(width.truncate());
    if (size == null || !_isCurrent(generation)) return;
    final ad = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (loaded) async {
          final banner = loaded as BannerAd;
          final platformSize = await banner.getPlatformAdSize();
          if (!_isCurrent(generation) || platformSize == null) {
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

  /// Drops the ad now; disposes it after the frame that removes its widget.
  void _release() {
    _generation++;
    final old = _ad;
    _ad = null;
    _size = null;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void dispose() {
    _generation++;
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (_width == null && constraints.maxWidth.isFinite) {
        _width = constraints.maxWidth;
        if (_visible) _load(constraints.maxWidth);
      }
      final ad = _ad;
      final size = _size;
      if (ad == null || size == null) return const SizedBox.shrink();
      return widget.builder(context, AdWidget(ad: ad), size);
    },
  );
}
