/// Tiny cross-manager coordinator so App Open and Interstitial ads never
/// show at the same time.
class AdsState {
  AdsState._();

  static bool isFullScreenAdShowing = false;
}
