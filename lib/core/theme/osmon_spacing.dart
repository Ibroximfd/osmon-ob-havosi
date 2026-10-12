/// Spacing, radius and size tokens (logical pixels).
abstract final class OsmonSpace {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;

  /// Side gutter of every screen.
  static const double gutter = s16;
}

abstract final class OsmonRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;
}

abstract final class OsmonSize {
  static const double tapTarget = 48;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double glyphSm = 22;
  static const double glyphMd = 30;
  static const double glyphLg = 56;
  static const double glyphHero = 72;
  static const double navBarHeight = 64;

  /// Space the floating nav bar occupies, so scroll content can clear it.
  static const double navBarClearance = 96;
  static const double hourCellWidth = 58;
  static const double chartHeight = 64;
  static const double sparkHeight = 28;
  static const double rangeBarHeight = 5;
  static const double switchWidth = 36;
  static const double mapPanelHeight = 260;
  static const double radarPanelHeight = 300;
  static const double sunArcHeight = 92;
  static const double moonDisc = 44;
  static const double avatar = 32;
  static const double strokeHairline = 1;
  static const double strokeIcon = 1.7;
  static const double progressBar = 4;
  static const double maxContentWidth = 560;

  // Skeleton shapes mirror the real cards they stand in for.
  static const double skeletonLabelWidth = 160;
  static const double skeletonHeroWidth = 180;
  static const double skeletonHeroHeight = 96;
  static const double skeletonCardHeight = 72;
  static const double hourStripHeight = 116;
  static const double skeletonListHeight = 280;
  static const double sheetHourRowHeight = 92;
  static const double healthAqiCardHeight = 170;
  static const double healthPollenCardHeight = 200;
}

abstract final class OsmonBreakpoints {
  static const double compact = 360;
  static const double medium = 600;
}
