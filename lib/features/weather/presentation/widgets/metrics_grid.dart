import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/services/pressure_trend.dart';

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({
    super.key,
    required this.forecast,
    required this.trend,
    required this.formats,
  });

  final Forecast forecast;
  final PressureTrend? trend;
  final Formats formats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = forecast.current;
    final today = forecast.today;
    final uv = current.isDay ? current.uvIndex : (today?.uvIndexMax ?? 0);
    final visibilityKm = current.visibility / 1000;
    return TileGrid(
      children: <Widget>[
        MetricTile(
          icon: LucideIcons.sun,
          label: l10n.metricUv,
          value: uv.round().toString(),
          caption: _uvCaption(l10n, uv),
        ),
        MetricTile(
          icon: LucideIcons.wind,
          label: l10n.metricWind,
          value: formats.wind(current.windSpeed),
          caption: l10n.windGustsFrom(
            _direction(l10n, current.windDirection),
            formats.wind(current.windGusts),
          ),
        ),
        MetricTile(
          icon: LucideIcons.droplets,
          label: l10n.metricHumidity,
          value: formats.percent(current.humidity),
          caption: l10n.dewPoint(formats.temperature(current.dewPoint)),
        ),
        MetricTile(
          icon: LucideIcons.gauge,
          label: l10n.metricPressure,
          value:
              '${formats.pressureValue(current.pressure)} '
              '${formats.pressureUnitLabel}',
          caption: switch (trend?.direction) {
            PressureDirection.falling => l10n.pressureFalling(
              formats.pressureDelta(trend!.change24h),
            ),
            PressureDirection.rising => l10n.pressureRising(
              formats.pressureDelta(trend!.change24h),
            ),
            _ => l10n.pressureSteady,
          },
        ),
        MetricTile(
          icon: LucideIcons.eye,
          label: l10n.metricVisibility,
          value: l10n.visibilityKm(
            visibilityKm >= 10
                ? visibilityKm.round().toString()
                : visibilityKm.toStringAsFixed(1),
          ),
          caption: visibilityKm < 1 ? l10n.visibilityPoor : l10n.visibilityGood,
        ),
        if (today != null)
          MetricTile(
            icon: LucideIcons.sunrise,
            label: l10n.metricSun,
            value:
                '${formats.time(today.sunrise)} – ${formats.time(today.sunset)}',
            caption: l10n.daylightLength(formats.duration(today.daylight)),
          ),
      ],
    );
  }

  static String _uvCaption(AppLocalizations l10n, double uv) {
    if (uv < 3) return l10n.uvCaptionLow;
    if (uv < 6) return l10n.uvCaptionModerate;
    if (uv < 8) return l10n.uvCaptionHigh;
    return l10n.uvCaptionVeryHigh;
  }

  /// Wind direction is where it blows *from*, in eight sectors.
  static String _direction(AppLocalizations l10n, double degrees) {
    final sector = ((degrees % 360) / 45).round() % 8;
    return <String>[
      l10n.windN,
      l10n.windNE,
      l10n.windE,
      l10n.windSE,
      l10n.windS,
      l10n.windSW,
      l10n.windW,
      l10n.windNW,
    ][sector];
  }
}
