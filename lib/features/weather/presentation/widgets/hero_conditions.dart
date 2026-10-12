import 'package:flutter/material.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/weather_glyph.dart';
import '../../domain/entities/forecast.dart';

/// The one big number, with the condition and today's range under it.
class HeroConditions extends StatelessWidget {
  const HeroConditions({
    super.key,
    required this.forecast,
    required this.formats,
    required this.tint,
  });

  final Forecast forecast;
  final Formats formats;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final current = forecast.current;
    final today = forecast.today;
    final condition = formats.condition(current.condition);
    return Padding(
      padding: const EdgeInsets.only(
        top: OsmonSpace.s24,
        bottom: OsmonSpace.s8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  label:
                      '${formats.temperature(current.temperature)}, $condition',
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formats.temperatureValue(current.temperature),
                            style: OsmonType.hero,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: OsmonSpace.s8),
                        child: Text(
                          '°',
                          style: OsmonType.heroUnit.copyWith(color: tint),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OsmonSpace.s10),
                Text(condition, style: OsmonType.bodyLarge),
                const SizedBox(height: OsmonSpace.s2),
                Text(
                  <String>[
                    context.l10n.homeFeelsLike(
                      formats.temperature(current.apparentTemperature),
                    ),
                    if (today != null)
                      '↑${formats.temperature(today.maxTemperature)}  '
                          '↓${formats.temperature(today.minTemperature)}',
                  ].join('  ·  '),
                  style: OsmonType.caption.copyWith(
                    color: OsmonColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          WeatherGlyph(
            kind: GlyphKind.of(current.condition, isDay: current.isDay),
            size: OsmonSize.glyphHero,
            animate: true,
          ),
        ],
      ),
    );
  }
}

/// "6° warmer than this day last year" — the line people screenshot.
class LastYearChip extends StatelessWidget {
  const LastYearChip({super.key, required this.delta, required this.formats});

  final double delta;
  final Formats formats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rounded = delta.round();
    final text = rounded.abs() < 1
        ? l10n.lastYearSame
        : rounded > 0
        ? l10n.lastYearWarmer(
            formats.temperatureDelta(delta).replaceAll('+', ''),
          )
        : l10n.lastYearColder(
            formats.temperatureDelta(-delta).replaceAll('+', ''),
          );
    final color = rounded > 0
        ? OsmonColors.warm
        : rounded < 0
        ? OsmonColors.cold
        : OsmonColors.textSecondary;
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(OsmonRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OsmonSpace.s12,
            vertical: OsmonSpace.s6,
          ),
          child: Text(text, style: OsmonType.captionStrong),
        ),
      ),
    );
  }
}
