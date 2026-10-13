import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../ads/widgets/inline_banner_ad.dart';
import '../../../../ads/widgets/native_ad_card.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/bloc/load_status.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/reveal.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../location/domain/location_repository.dart';
import '../../../settings/presentation/formats_of.dart';
import '../../../settings/presentation/widgets/notifications_blocked_notice.dart';
import '../bloc/weather_bloc.dart';
import 'daily_list.dart';
import 'day_detail_sheet.dart';
import 'day_story_card.dart';
import 'hero_conditions.dart';
import 'home_empty_view.dart';
import 'home_header.dart';
import 'home_skeleton.dart';
import 'hourly_strip.dart';
import 'life_index_grid.dart';
import 'metrics_grid.dart';
import 'outlook_card.dart';
import 'quick_access_grid.dart';
import 'today_shortcuts.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WeatherBloc, WeatherState>(
    builder: (context, state) {
      final bloc = context.read<WeatherBloc>();
      if (state.forecast != null) return _HomeContent(state: state);
      return switch (state.status) {
        LoadStatus.initial || LoadStatus.loading => const HomeSkeleton(),
        LoadStatus.empty => HomeEmptyView(
          isLocating: state.isLocating,
          onLocate: () => bloc.add(const WeatherLocateRequested()),
          onSearch: () => context.push(AppRoutes.search),
        ),
        LoadStatus.failure ||
        LoadStatus.offline ||
        LoadStatus.ready => SafeArea(
          child: Center(
            child: ErrorStateView(
              failure: state.failure,
              onRetry: () => bloc.add(
                state.place == null
                    ? const WeatherStarted()
                    : const WeatherRefreshed(),
              ),
            ),
          ),
        ),
      };
    },
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final WeatherState state;

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<WeatherBloc>()..add(const WeatherRefreshed());
    await bloc.stream.firstWhere(
      (s) => !s.isRefreshing && s.status != LoadStatus.loading,
    );
  }

  void _open(BuildContext context, QuickDestination destination) =>
      context.push(switch (destination) {
        QuickDestination.field => AppRoutes.field,
        QuickDestination.alerts => AppRoutes.alerts,
        QuickDestination.photo => AppRoutes.photo,
        QuickDestination.chat => AppRoutes.chat,
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formats = formatsOf(context);
    final forecast = state.forecast!;
    final place = state.place ?? forecast.place;
    final tint = state.scene.palette.tint;
    final isFavorite = context.select<FavoritesBloc, bool>(
      (bloc) => bloc.state.contains(place),
    );
    final locationAccess = state.locationAccess;
    final lastYear = state.lastYearDelta;
    final story = state.dayStory;
    final today = forecast.fetchedAt;

    final sections = <Widget>[
      HomeHeader(
        place: place,
        subtitle: <String>[
          if (place.region != null) place.region!,
          l10n.stateUpdatedAt(formats.time(forecast.fetchedAt)),
        ].join(' · '),
        isFavorite: isFavorite,
        tint: tint,
        onSearch: () => context.push(AppRoutes.search),
        onToggleFavorite: () =>
            context.read<FavoritesBloc>().add(FavoriteToggled(place)),
        onChat: () => context.push(AppRoutes.chat),
      ),
      if (state.needsLocationAccess && locationAccess != null)
        LocationHintCard(
          access: locationAccess,
          cityName: place.name,
          onEnable: () => _enableLocation(context, locationAccess),
        ),
      const Padding(
        padding: EdgeInsets.only(top: OsmonSpace.s12),
        child: NotificationsBlockedNotice(),
      ),
      HeroConditions(forecast: forecast, formats: formats, tint: tint),
      if (lastYear != null) LastYearChip(delta: lastYear, formats: formats),
      const SizedBox(height: OsmonSpace.s16),
      if (state.status == LoadStatus.offline) ...<Widget>[
        OfflineBanner(
          updatedAt: formats.time(forecast.fetchedAt),
          onRetry: () =>
              context.read<WeatherBloc>().add(const WeatherRefreshed()),
        ),
        const SizedBox(height: OsmonSpace.s10),
      ],
      OutlookCard(
        outlook: state.outlook,
        nowcast: forecast.nowcast.take(8).toList(),
        air: forecast.air,
        formats: formats,
        tint: tint,
        onTap: () => context.go(AppRoutes.radar),
      ),
      TodayShortcuts(
        formats: formats,
        tint: tint,
        onPrayer: () => context.push(AppRoutes.prayer),
        onRoute: () => context.push(AppRoutes.route),
      ),
      Eyebrow(l10n.sectionHourly),
      HourlyStrip(hours: forecast.hourly, formats: formats, tint: tint),
      Eyebrow(l10n.sectionDaily),
      DailyList(
        days: forecast.daily,
        today: today,
        formats: formats,
        onDayTap: (day) => DayDetailSheet.show(
          context,
          day: day,
          hours: forecast.hourly,
          title:
              '${formats.dayLabel(day.date, today)}, ${formats.dayMonth(day.date)}',
          formats: formats,
        ),
      ),
      Eyebrow(l10n.sectionNow),
      MetricsGrid(
        forecast: forecast,
        trend: state.pressureTrend,
        formats: formats,
      ),
      const Padding(
        padding: EdgeInsets.only(top: OsmonSpace.s16),
        child: NativeAdCard(slotKey: 'home_mid'),
      ),
      Eyebrow(l10n.sectionIndices),
      LifeIndexGrid(indices: state.lifeIndices),
      Eyebrow(l10n.sectionQuick),
      QuickAccessGrid(tint: tint, onOpen: (d) => _open(context, d)),
      if (story != null) ...<Widget>[
        const SizedBox(height: OsmonSpace.s16),
        DayStoryCard(
          story: story,
          aiText: state.aiStory,
          formats: formats,
          tint: tint,
        ),
      ],
      const InlineBannerAd(),
      Padding(
        padding: const EdgeInsets.only(top: OsmonSpace.s20),
        child: Text(
          l10n.dataAttribution,
          textAlign: TextAlign.center,
          style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
        ),
      ),
    ];

    return SkyScrollView(
      onRefresh: () => _refresh(context),
      slivers: <Widget>[
        SliverList.list(
          children: <Widget>[
            for (var i = 0; i < sections.length; i++)
              Reveal(order: i, child: sections[i]),
          ],
        ),
      ],
    );
  }

  /// The system dialog can only ask while access is merely denied; after
  /// that, and for switched-off location, the settings screen is the way.
  void _enableLocation(BuildContext context, LocationAccess access) =>
      context.read<WeatherBloc>().add(
        access == LocationAccess.denied
            ? const WeatherLocateRequested()
            : const WeatherLocationSettingsOpened(),
      );
}
