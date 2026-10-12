import 'package:flutter/painting.dart';

/// Colour tokens. The app is one visual world — white type over a living sky
/// behind a glass layer — so there is a single palette, not light/dark pairs.
/// Samarkand majolica turquoise is the accent; dome gold marks warmth.
abstract final class OsmonColors {
  static const Color ink = Color(0xFF06101C);
  static const Color inkRaised = Color(0xFF0C1828);
  static const Color inkSheet = Color(0xF20B1524);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB8FFFFFF);
  static const Color textTertiary = Color(0x8CFFFFFF);
  static const Color textOnAccent = Color(0xFF04141B);

  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassFillStrong = Color(0x2BFFFFFF);
  static const Color glassStroke = Color(0x2BFFFFFF);
  static const Color glassStrokeSoft = Color(0x14FFFFFF);
  static const Color glassShade = Color(0x40050B14);
  static const Color divider = Color(0x14FFFFFF);
  static const Color navBar = Color(0x8C0A101C);
  static const Color scrim = Color(0x99050A12);

  // Readability veil laid over the sky, top to bottom.
  static const Color veilTop = Color(0x4D000000);
  static const Color veilClear = Color(0x00000000);
  static const Color veilMid = Color(0x1A000000);
  static const Color veilBottom = Color(0x9E000000);

  static const Color accent = Color(0xFF3BC3DC);
  static const Color accentSoft = Color(0x403BC3DC);
  static const Color gold = Color(0xFFEFB844);
  static const Color goldSoft = Color(0x40EFB844);

  // Semantic severity — separate from the accent, always paired with text.
  static const Color good = Color(0xFF5DD6A2);
  static const Color moderate = Color(0xFFF0C84A);
  static const Color elevated = Color(0xFFF09A4A);
  static const Color severe = Color(0xFFEF6A5E);
  static const Color extreme = Color(0xFFB57BE0);

  static const Color goodSoft = Color(0x405DD6A2);
  static const Color moderateSoft = Color(0x40F0C84A);
  static const Color elevatedSoft = Color(0x47F09A4A);
  static const Color severeSoft = Color(0x4DEF6A5E);

  // Data encodings on the map and charts.
  static const Color precipLight = Color(0xFF6FD3A8);
  static const Color precipModerate = Color(0xFFF0C84A);
  static const Color precipHeavy = Color(0xFFE2794A);
  static const Color precipExtreme = Color(0xFFC4453E);
  static const Color cold = Color(0xFF7FB6FF);
  static const Color mild = Color(0xFF7FDCC4);
  static const Color warm = Color(0xFFF2C14E);
  static const Color hot = Color(0xFFF07A4A);
  static const Color sunCore = Color(0xFFFFE3A0);
  static const Color moonCore = Color(0xFFE8EFFB);
  static const Color star = Color(0xFFFFF6DC);
  static const Color rainDrop = Color(0xFFBEE2F5);
  static const Color snowFlake = Color(0xFFFFFFFF);
  static const Color dustMote = Color(0xFFF0CE8C);
  static const Color fogBand = Color(0xFFECF2F6);
  static const Color lightning = Color(0xFFE2F0FF);
}
