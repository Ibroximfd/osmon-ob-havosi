import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/osmon_button.dart';
import '../../../../core/widgets/osmon_chip.dart';
import '../../domain/weather_grid.dart';
import 'weather_layer_colors.dart';

String layerLabel(AppLocalizations l10n, MapLayer layer) => switch (layer) {
  MapLayer.temperature => l10n.layerTemperature,
  MapLayer.precipitation => l10n.layerPrecipitation,
  MapLayer.wind => l10n.layerWind,
  MapLayer.clouds => l10n.layerClouds,
  MapLayer.airQuality => l10n.layerAirQuality,
};

class LayerChips extends StatelessWidget {
  const LayerChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.tint,
  });

  final MapLayer selected;
  final ValueChanged<MapLayer> onSelected;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final icons = <MapLayer, IconData>{
      MapLayer.temperature: LucideIcons.thermometer,
      MapLayer.precipitation: LucideIcons.cloudRain,
      MapLayer.wind: LucideIcons.wind,
      MapLayer.clouds: LucideIcons.cloud,
      MapLayer.airQuality: LucideIcons.leaf,
    };
    return ChipStrip(
      children: <Widget>[
        for (final layer in MapLayer.values)
          OsmonChip(
            label: layerLabel(l10n, layer),
            icon: icons[layer],
            selected: layer == selected,
            tint: tint,
            onTap: () => onSelected(layer),
          ),
      ],
    );
  }
}

/// Zoom and recentre, stacked on the map's right edge.
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OsmonIconButton(
          icon: LucideIcons.plus,
          tooltip: l10n.mapZoomIn,
          onPressed: onZoomIn,
        ),
        const SizedBox(height: OsmonSpace.s8),
        OsmonIconButton(
          icon: LucideIcons.minus,
          tooltip: l10n.mapZoomOut,
          onPressed: onZoomOut,
        ),
        const SizedBox(height: OsmonSpace.s8),
        OsmonIconButton(
          icon: LucideIcons.locateFixed,
          tooltip: l10n.mapMyPlace,
          onPressed: onRecenter,
        ),
      ],
    );
  }
}

/// A gradient bar with low/high ends labelled for the active layer.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key, required this.layer, required this.formats});

  final MapLayer layer;
  final Formats formats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (colors, low, high) = switch (layer) {
      MapLayer.temperature => (
        <Color>[
          for (final t in <double>[-10, 0, 10, 20, 30, 40])
            WeatherLayerColors.temperature(t),
        ],
        formats.temperature(-10),
        formats.temperature(40),
      ),
      MapLayer.precipitation => (
        <Color>[
          OsmonColors.precipLight,
          OsmonColors.precipModerate,
          OsmonColors.precipHeavy,
          OsmonColors.precipExtreme,
        ],
        l10n.intensityLight,
        l10n.intensityHeavy,
      ),
      MapLayer.wind => (
        <Color>[OsmonColors.glassFillStrong, OsmonColors.textPrimary],
        '0 ${formats.windUnitLabel}',
        '${formats.windValue(40)} ${formats.windUnitLabel}',
      ),
      MapLayer.clouds => (
        <Color>[OsmonColors.glassFill, OsmonColors.textPrimary],
        formats.percent(0),
        formats.percent(100),
      ),
      MapLayer.airQuality => (
        <Color>[
          for (final aqi in <double>[25, 75, 125, 175, 250])
            WeatherLayerColors.airQuality(aqi),
        ],
        l10n.legendLow,
        l10n.legendHigh,
      ),
    };
    return GlassPanel(
      fill: OsmonColors.inkSheet,
      radius: OsmonRadius.md,
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s12,
        vertical: OsmonSpace.s8,
      ),
      child: Row(
        children: <Widget>[
          Text(low, style: OsmonType.micro),
          const SizedBox(width: OsmonSpace.s8),
          Expanded(
            child: Container(
              height: OsmonSize.progressBar + OsmonSpace.s2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(OsmonRadius.pill),
                gradient: LinearGradient(colors: colors),
              ),
            ),
          ),
          const SizedBox(width: OsmonSpace.s8),
          Text(high, style: OsmonType.micro),
        ],
      ),
    );
  }
}

/// Play/pause plus a slider over the 15-minute precipitation steps.
class PrecipitationTimeline extends StatelessWidget {
  const PrecipitationTimeline({
    super.key,
    required this.stepTimes,
    required this.step,
    required this.isPlaying,
    required this.formats,
    required this.tint,
    required this.onStep,
    required this.onTogglePlay,
  });

  final List<DateTime> stepTimes;
  final int step;
  final bool isPlaying;
  final Formats formats;
  final Color tint;
  final ValueChanged<int> onStep;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (stepTimes.length < 2) return const SizedBox.shrink();
    final current = stepTimes[step.clamp(0, stepTimes.length - 1)];
    return GlassPanel(
      fill: OsmonColors.inkSheet,
      radius: OsmonRadius.md,
      padding: const EdgeInsets.fromLTRB(
        OsmonSpace.s4,
        OsmonSpace.s2,
        OsmonSpace.s14,
        OsmonSpace.s2,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: isPlaying ? l10n.radarPause : l10n.radarPlay,
            onPressed: onTogglePlay,
            icon: Icon(
              isPlaying ? LucideIcons.pause : LucideIcons.play,
              size: OsmonSize.iconMd,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: tint,
                inactiveTrackColor: OsmonColors.glassFillStrong,
                thumbColor: OsmonColors.textPrimary,
                overlayColor: tint.withValues(alpha: 0.2),
                trackHeight: OsmonSize.progressBar,
              ),
              child: Slider(
                value: step.toDouble(),
                max: (stepTimes.length - 1).toDouble(),
                divisions: stepTimes.length - 1,
                label: formats.time(current),
                onChanged: (value) => onStep(value.round()),
              ),
            ),
          ),
          Text(
            step == 0 ? l10n.relativeNow : formats.time(current),
            style: OsmonType.captionStrong,
          ),
        ],
      ),
    );
  }
}
