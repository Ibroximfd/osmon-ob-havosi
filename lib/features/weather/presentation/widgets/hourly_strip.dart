import 'package:flutter/material.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/weather_glyph.dart';
import '../../domain/entities/forecast.dart';

/// Next 24 hours as a horizontally scrolling strip; "now" is highlighted.
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({
    super.key,
    required this.hours,
    required this.formats,
    required this.tint,
  });

  final List<HourlyWeather> hours;
  final Formats formats;
  final Color tint;

  static const int _count = 24;

  @override
  Widget build(BuildContext context) {
    final visible = hours.take(_count).toList();
    return SizedBox(
      height: OsmonSize.hourStripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: OsmonSpace.s8),
        itemBuilder: (context, index) => _HourCell(
          hour: visible[index],
          isNow: index == 0,
          label: index == 0
              ? context.l10n.relativeNow
              : formats.hour(visible[index].time),
          temperature: formats.temperature(visible[index].temperature),
          tint: tint,
        ),
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  const _HourCell({
    required this.hour,
    required this.isNow,
    required this.label,
    required this.temperature,
    required this.tint,
  });

  final HourlyWeather hour;
  final bool isNow;
  final String label;
  final String temperature;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final chance = hour.precipitationProbability.round();
    return Container(
      width: OsmonSize.hourCellWidth,
      padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s10),
      decoration: BoxDecoration(
        color: isNow ? tint.withValues(alpha: 0.3) : OsmonColors.glassFill,
        borderRadius: BorderRadius.circular(OsmonRadius.lg),
        border: Border.all(
          color: isNow
              ? tint.withValues(alpha: 0.6)
              : OsmonColors.glassStrokeSoft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: OsmonType.micro.copyWith(color: OsmonColors.textSecondary),
            maxLines: 1,
          ),
          WeatherGlyph(
            kind: GlyphKind.of(hour.condition, isDay: hour.isDay),
            size: OsmonSize.glyphSm,
          ),
          Text(temperature, style: OsmonType.bodyStrong),
          Text(
            chance >= 10 ? '$chance%' : ' ',
            style: OsmonType.micro.copyWith(
              color: OsmonColors.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
