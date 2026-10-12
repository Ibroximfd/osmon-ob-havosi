import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/bloc/load_status.dart';
import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../domain/astronomy.dart';
import '../../domain/prayer_day.dart';
import '../bloc/prayer_bloc.dart';
import '../prayer_labels.dart';
import 'sky_dials.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = context.select<WeatherBloc, Color>(
      (bloc) => bloc.state.scene.palette.tint,
    );
    return Scaffold(
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          final formats = formatsOf(context);
          final now = state.now;
          return SkyScrollView(
            clearNavBar: false,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l10n.prayerTitle,
                  subtitle: state.place == null || now == null
                      ? null
                      : '${state.place!.name} · ${formats.dayMonth(now)}, '
                            '${formats.weekday(now)}',
                  showBack: true,
                ),
              ),
              SliverToBoxAdapter(
                child: switch (state.status) {
                  LoadStatus.initial ||
                  LoadStatus.loading => const ShimmerScope(
                    child: Padding(
                      padding: EdgeInsets.only(top: OsmonSpace.s16),
                      child: SkeletonBlock(
                        height: OsmonSize.skeletonListHeight,
                        radius: OsmonRadius.lg,
                      ),
                    ),
                  ),
                  LoadStatus.empty ||
                  LoadStatus.failure ||
                  LoadStatus.offline => MessageStateView(
                    icon: LucideIcons.mapPin,
                    title: l10n.homeEmptyTitle,
                    message: l10n.homeEmptyMessage,
                  ),
                  LoadStatus.ready => _PrayerContent(
                    state: state,
                    formats: formats,
                    tint: tint,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrayerContent extends StatelessWidget {
  const _PrayerContent({
    required this.state,
    required this.formats,
    required this.tint,
  });

  final PrayerState state;
  final Formats formats;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = state.next;
    final until = state.untilNext;
    final sun = state.sun;
    final moon = state.moon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: OsmonSpace.s16),
        if (next != null && until != null)
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.prayerNext.toUpperCase(), style: OsmonType.eyebrow),
                const SizedBox(height: OsmonSpace.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            prayerName(l10n, next.key),
                            style: OsmonType.bodyLarge,
                          ),
                          Text(
                            formats.time(next.value),
                            style: OsmonType.numberLarge,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.prayerRemaining(formats.duration(until)),
                      style: OsmonType.captionStrong.copyWith(color: tint),
                    ),
                  ],
                ),
                const SizedBox(height: OsmonSpace.s12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(OsmonRadius.pill),
                  child: LinearProgressIndicator(
                    value: state.progressToNext,
                    minHeight: OsmonSize.progressBar,
                    color: tint,
                    backgroundColor: OsmonColors.glassFill,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: OsmonSpace.s10),
        _TimesList(state: state, formats: formats, tint: tint),
        Padding(
          padding: const EdgeInsets.only(top: OsmonSpace.s8),
          child: Text(
            l10n.prayerMethodLine(_methodName(l10n, state.method)),
            style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
          ),
        ),
        if (sun != null) ...<Widget>[
          Eyebrow(l10n.sunTitle),
          _SunCard(sun: sun, now: state.now!, formats: formats, tint: tint),
        ],
        if (moon != null) ...<Widget>[
          Eyebrow(l10n.moonTitle),
          GlassPanel(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _moonName(l10n, moon.name),
                        style: OsmonType.bodyStrong,
                      ),
                      const SizedBox(height: OsmonSpace.s2),
                      Text(
                        l10n.moonIllumination(
                          formats.percent(moon.illumination * 100),
                        ),
                        style: OsmonType.caption.copyWith(
                          color: OsmonColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                MoonDisc(
                  illumination: moon.illumination,
                  isWaxing: moon.isWaxing,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _methodName(AppLocalizations l10n, PrayerMethod method) =>
      switch (method) {
        PrayerMethod.uzbekistan => l10n.methodUzbekistan,
        PrayerMethod.muslimWorldLeague => l10n.methodMwl,
        PrayerMethod.karachi => l10n.methodKarachi,
        PrayerMethod.ummAlQura => l10n.methodUmmAlQura,
        PrayerMethod.isna => l10n.methodIsna,
      };

  static String _moonName(AppLocalizations l10n, MoonPhaseName name) =>
      switch (name) {
        MoonPhaseName.newMoon => l10n.moonNew,
        MoonPhaseName.waxingCrescent => l10n.moonWaxingCrescent,
        MoonPhaseName.firstQuarter => l10n.moonFirstQuarter,
        MoonPhaseName.waxingGibbous => l10n.moonWaxingGibbous,
        MoonPhaseName.fullMoon => l10n.moonFull,
        MoonPhaseName.waningGibbous => l10n.moonWaningGibbous,
        MoonPhaseName.lastQuarter => l10n.moonLastQuarter,
        MoonPhaseName.waningCrescent => l10n.moonWaningCrescent,
      };
}

class _TimesList extends StatelessWidget {
  const _TimesList({
    required this.state,
    required this.formats,
    required this.tint,
  });

  final PrayerState state;
  final Formats formats;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = state.today!.ordered;
    final current = state.current;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s14,
        vertical: OsmonSpace.s4,
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < entries.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, color: OsmonColors.divider),
            Semantics(
              selected: entries[i].key == current,
              child: SizedBox(
                height: OsmonSize.tapTarget,
                child: Row(
                  children: <Widget>[
                    Icon(
                      entries[i].key == Prayer.sunrise
                          ? LucideIcons.sunrise
                          : LucideIcons.moon,
                      size: OsmonSize.iconSm,
                      color: entries[i].key == current
                          ? tint
                          : OsmonColors.textTertiary,
                    ),
                    const SizedBox(width: OsmonSpace.s12),
                    Expanded(
                      child: Text(
                        prayerName(l10n, entries[i].key),
                        style:
                            (entries[i].key == current
                                    ? OsmonType.bodyStrong
                                    : OsmonType.body)
                                .copyWith(
                                  color: entries[i].key == current
                                      ? tint
                                      : null,
                                ),
                      ),
                    ),
                    Text(
                      formats.time(entries[i].value),
                      style: OsmonType.bodyStrong.copyWith(
                        color: entries[i].key == current ? tint : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SunCard extends StatelessWidget {
  const _SunCard({
    required this.sun,
    required this.now,
    required this.formats,
    required this.tint,
  });

  final SunDay sun;
  final DateTime now;
  final Formats formats;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = sun.progressAt(now);
    final rise = sun.sunrise;
    final set = sun.sunset;
    final daylight = sun.daylight;
    String window(TimeWindow? w) =>
        w == null ? '—' : '${formats.time(w.start)}–${formats.time(w.end)}';
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SunArc(progress: progress, tint: tint),
          const SizedBox(height: OsmonSpace.s6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                rise == null ? '—' : formats.time(rise),
                style: OsmonType.captionStrong,
              ),
              Text(
                l10n.sunNoon(formats.time(sun.solarNoon)),
                style: OsmonType.micro.copyWith(
                  color: OsmonColors.textSecondary,
                ),
              ),
              Text(
                set == null ? '—' : formats.time(set),
                style: OsmonType.captionStrong,
              ),
            ],
          ),
          if (progress == null) ...<Widget>[
            const SizedBox(height: OsmonSpace.s6),
            Text(
              l10n.sunBelowHorizon,
              style: OsmonType.caption.copyWith(
                color: OsmonColors.textSecondary,
              ),
            ),
          ],
          if (daylight != null) ...<Widget>[
            const SizedBox(height: OsmonSpace.s6),
            Text(
              l10n.daylightLength(formats.duration(daylight)),
              style: OsmonType.caption.copyWith(
                color: OsmonColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: OsmonSpace.s12),
          const Divider(height: 1, color: OsmonColors.divider),
          const SizedBox(height: OsmonSpace.s12),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1.2),
            },
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  const SizedBox.shrink(),
                  Text(l10n.morning.toUpperCase(), style: OsmonType.eyebrow),
                  Text(l10n.evening.toUpperCase(), style: OsmonType.eyebrow),
                ],
              ),
              _windowRow(
                l10n.goldenHour,
                window(sun.morningGoldenHour),
                window(sun.eveningGoldenHour),
                OsmonColors.gold,
              ),
              _windowRow(
                l10n.blueHour,
                window(sun.morningBlueHour),
                window(sun.eveningBlueHour),
                OsmonColors.cold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static TableRow _windowRow(
    String label,
    String morning,
    String evening,
    Color dot,
  ) => TableRow(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: OsmonSpace.s8),
        child: Row(
          children: <Widget>[
            Container(
              width: OsmonSpace.s8,
              height: OsmonSpace.s8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: OsmonSpace.s6),
            Flexible(child: Text(label, style: OsmonType.caption)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: OsmonSpace.s8),
        child: Text(morning, style: OsmonType.captionStrong),
      ),
      Padding(
        padding: const EdgeInsets.only(top: OsmonSpace.s8),
        child: Text(evening, style: OsmonType.captionStrong),
      ),
    ],
  );
}
