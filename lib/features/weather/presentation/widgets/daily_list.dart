import 'package:flutter/material.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/weather_glyph.dart';
import '../../domain/entities/forecast.dart';

/// Ten days with a shared temperature scale, so the bars compare across
/// rows the way a reader expects.
class DailyList extends StatelessWidget {
  const DailyList({
    super.key,
    required this.days,
    required this.today,
    required this.formats,
    required this.onDayTap,
  });

  final List<DailyWeather> days;
  final DateTime today;
  final Formats formats;
  final ValueChanged<DailyWeather> onDayTap;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final low = days
        .map((d) => d.minTemperature)
        .reduce((a, b) => a < b ? a : b);
    final high = days
        .map((d) => d.maxTemperature)
        .reduce((a, b) => a > b ? a : b);
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s14,
        vertical: OsmonSpace.s6,
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < days.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, color: OsmonColors.divider),
            _DayRow(
              day: days[i],
              label: formats.dayLabel(days[i].date, today),
              min: formats.temperature(days[i].minTemperature),
              max: formats.temperature(days[i].maxTemperature),
              scaleLow: low,
              scaleHigh: high,
              onTap: () => onDayTap(days[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.label,
    required this.min,
    required this.max,
    required this.scaleLow,
    required this.scaleHigh,
    required this.onTap,
  });

  final DailyWeather day;
  final String label;
  final String min;
  final String max;
  final double scaleLow;
  final double scaleHigh;
  final VoidCallback onTap;

  static const double _labelWidth = 92;
  static const double _valueWidth = 36;
  static const double _chanceWidth = 34;

  @override
  Widget build(BuildContext context) {
    final chance = day.precipitationProbability.round();
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: OsmonSize.tapTarget),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: _labelWidth,
              child: Text(
                label,
                style: OsmonType.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            WeatherGlyph(
              kind: GlyphKind.of(day.condition, isDay: true),
              size: OsmonSize.glyphSm,
            ),
            SizedBox(
              width: _chanceWidth,
              child: Text(
                chance >= 20 ? '$chance%' : '',
                textAlign: TextAlign.center,
                style: OsmonType.micro.copyWith(
                  color: OsmonColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(
              width: _valueWidth,
              child: Text(
                min,
                textAlign: TextAlign.right,
                style: OsmonType.body.copyWith(color: OsmonColors.textTertiary),
              ),
            ),
            const SizedBox(width: OsmonSpace.s8),
            Expanded(
              child: TemperatureRangeBar(
                low: day.minTemperature,
                high: day.maxTemperature,
                scaleLow: scaleLow,
                scaleHigh: scaleHigh,
              ),
            ),
            const SizedBox(width: OsmonSpace.s8),
            SizedBox(
              width: _valueWidth,
              child: Text(max, style: OsmonType.bodyStrong),
            ),
          ],
        ),
      ),
    );
  }
}

/// A day's min–max as a segment on a shared scale, coloured cold → hot.
class TemperatureRangeBar extends StatelessWidget {
  const TemperatureRangeBar({
    super.key,
    required this.low,
    required this.high,
    required this.scaleLow,
    required this.scaleHigh,
  });

  final double low;
  final double high;
  final double scaleLow;
  final double scaleHigh;

  static Color colorFor(double celsius) {
    if (celsius <= 0) return OsmonColors.cold;
    if (celsius <= 15) {
      return Color.lerp(OsmonColors.cold, OsmonColors.mild, celsius / 15)!;
    }
    if (celsius <= 28) {
      return Color.lerp(
        OsmonColors.mild,
        OsmonColors.warm,
        (celsius - 15) / 13,
      )!;
    }
    return Color.lerp(
      OsmonColors.warm,
      OsmonColors.hot,
      ((celsius - 28) / 12).clamp(0, 1),
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final span = (scaleHigh - scaleLow).abs() < 1 ? 1 : scaleHigh - scaleLow;
    final start = ((low - scaleLow) / span).clamp(0.0, 1.0);
    final end = ((high - scaleLow) / span).clamp(start, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: OsmonSize.rangeBarHeight,
        decoration: BoxDecoration(
          color: OsmonColors.glassFill,
          borderRadius: BorderRadius.circular(OsmonRadius.pill),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: constraints.maxWidth * start,
              width: (constraints.maxWidth * (end - start)).clamp(
                OsmonSize.rangeBarHeight,
                constraints.maxWidth,
              ),
              top: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(OsmonRadius.pill),
                  gradient: LinearGradient(
                    colors: <Color>[colorFor(low), colorFor(high)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
