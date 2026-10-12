import 'package:flutter/material.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/weather_glyph.dart';
import '../../domain/entities/forecast.dart';

/// Bottom sheet with one day's hours and totals.
class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.day,
    required this.hours,
    required this.title,
    required this.formats,
  });

  final DailyWeather day;
  final List<HourlyWeather> hours;
  final String title;
  final Formats formats;

  static Future<void> show(
    BuildContext context, {
    required DailyWeather day,
    required List<HourlyWeather> hours,
    required String title,
    required Formats formats,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        DayDetailSheet(day: day, hours: hours, title: title, formats: formats),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dayHours = hours.where((h) => h.time.day == day.date.day).toList();
    final facts = <String>[
      l10n.daySheetPrecip(day.precipitationSum.toStringAsFixed(1)),
      l10n.daySheetChance(formats.percent(day.precipitationProbability)),
      l10n.daySheetGusts(formats.wind(day.windGustsMax)),
      l10n.daySheetUv(day.uvIndexMax.round().toString()),
      l10n.daySheetSun(formats.time(day.sunrise), formats.time(day.sunset)),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OsmonSpace.gutter,
          0,
          OsmonSpace.gutter,
          OsmonSpace.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                WeatherGlyph(
                  kind: GlyphKind.of(day.condition, isDay: true),
                  size: OsmonSize.glyphMd,
                ),
                const SizedBox(width: OsmonSpace.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: OsmonType.titleMedium),
                      Text(
                        '${formats.condition(day.condition)} · '
                        '${formats.temperature(day.minTemperature)} … '
                        '${formats.temperature(day.maxTemperature)}',
                        style: OsmonType.caption.copyWith(
                          color: OsmonColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: OsmonSpace.s16),
            Wrap(
              spacing: OsmonSpace.s8,
              runSpacing: OsmonSpace.s8,
              children: <Widget>[for (final fact in facts) _Fact(fact)],
            ),
            if (dayHours.isNotEmpty) ...<Widget>[
              const SizedBox(height: OsmonSpace.s20),
              SizedBox(
                height: OsmonSize.sheetHourRowHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dayHours.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: OsmonSpace.s12),
                  itemBuilder: (context, i) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        formats.hour(dayHours[i].time),
                        style: OsmonType.micro.copyWith(
                          color: OsmonColors.textSecondary,
                        ),
                      ),
                      WeatherGlyph(
                        kind: GlyphKind.of(
                          dayHours[i].condition,
                          isDay: dayHours[i].isDay,
                        ),
                        size: OsmonSize.glyphSm,
                      ),
                      Text(
                        formats.temperature(dayHours[i].temperature),
                        style: OsmonType.bodyStrong,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: OsmonColors.glassFill,
      borderRadius: BorderRadius.circular(OsmonRadius.sm),
      border: Border.all(color: OsmonColors.glassStrokeSoft),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s10,
        vertical: OsmonSpace.s6,
      ),
      child: Text(text, style: OsmonType.caption),
    ),
  );
}
