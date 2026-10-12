import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../ads/interstitial_ad_manager.dart';
import '../../../../core/bloc/load_status.dart';
import '../../../../core/domain/place.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../bloc/place_search_bloc.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.pickOnly});

  final bool pickOnly;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _choose(Place place) {
    if (widget.pickOnly) {
      context.pop(place);
      return;
    }
    context.read<WeatherBloc>().add(WeatherPlaceSelected(place));
    context.pop();
    // A natural pause point for an interstitial; frequency-capped inside.
    InterstitialAdManager.instance.maybeShowOnCitySwitch();
  }

  void _useLocation() {
    if (widget.pickOnly) {
      final current = context.read<WeatherBloc>().state.place;
      context.pop(current);
      return;
    }
    context.read<WeatherBloc>().add(const WeatherLocateRequested());
    context.pop();
  }

  void _clear() {
    _controller.clear();
    context.read<PlaceSearchBloc>().add(const PlaceQueryChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SkyScrollView(
        clearNavBar: false,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: ScreenHeader(title: l10n.searchTitle, showBack: true),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: OsmonSpace.s16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: OsmonType.bodyLarge,
                onChanged: (query) => context.read<PlaceSearchBloc>().add(
                  PlaceQueryChanged(query),
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: OsmonSize.iconMd,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: l10n.actionClear,
                            icon: const Icon(
                              LucideIcons.x,
                              size: OsmonSize.iconMd,
                            ),
                            onPressed: _clear,
                          ),
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
            builder: (context, state) => switch (state.status) {
              LoadStatus.initial => _Suggestions(
                onChoose: _choose,
                onUseLocation: _useLocation,
              ),
              LoadStatus.loading => const SliverToBoxAdapter(
                child: _ResultsSkeleton(),
              ),
              LoadStatus.failure || LoadStatus.offline => SliverToBoxAdapter(
                child: ErrorStateView(
                  failure: state.failure,
                  onRetry: () => context.read<PlaceSearchBloc>().add(
                    PlaceQueryChanged(state.query),
                  ),
                ),
              ),
              LoadStatus.empty || LoadStatus.ready =>
                state.hasNoMatches
                    ? SliverToBoxAdapter(
                        child: MessageStateView(
                          icon: LucideIcons.searchX,
                          title: l10n.searchNoResultsTitle(state.query),
                          message: l10n.searchNoResultsMessage,
                          actionLabel: l10n.actionClear,
                          onAction: _clear,
                        ),
                      )
                    : _PlaceSection(
                        title: l10n.searchResults,
                        places: state.results,
                        onChoose: _choose,
                      ),
            },
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onChoose, required this.onUseLocation});

  final ValueChanged<Place> onChoose;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favorites = context.select<FavoritesBloc, List<Place>>(
      (bloc) => bloc.state.places,
    );
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: OsmonSpace.s16),
            child: GlassPanel(
              onTap: onUseLocation,
              child: Row(
                children: <Widget>[
                  const Icon(
                    LucideIcons.locate,
                    size: OsmonSize.iconMd,
                    color: OsmonColors.accent,
                  ),
                  const SizedBox(width: OsmonSpace.s12),
                  Text(l10n.searchUseLocation, style: OsmonType.bodyStrong),
                ],
              ),
            ),
          ),
        ),
        if (favorites.isNotEmpty)
          _PlaceSection(
            title: l10n.searchFavorites,
            places: favorites,
            onChoose: onChoose,
            icon: LucideIcons.star,
          ),
        _PlaceSection(
          title: l10n.searchRegional,
          places: UzbekCities.regionalCentres,
          onChoose: onChoose,
        ),
      ],
    );
  }
}

class _PlaceSection extends StatelessWidget {
  const _PlaceSection({
    required this.title,
    required this.places,
    required this.onChoose,
    this.icon = LucideIcons.mapPin,
  });

  final String title;
  final List<Place> places;
  final ValueChanged<Place> onChoose;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: <Widget>[
      SliverToBoxAdapter(child: Eyebrow(title)),
      SliverToBoxAdapter(
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s4),
          child: Column(
            children: <Widget>[
              for (var i = 0; i < places.length; i++) ...<Widget>[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: OsmonSpace.s48,
                    color: OsmonColors.divider,
                  ),
                _PlaceRow(
                  key: ValueKey<String>(places[i].key),
                  place: places[i],
                  icon: icon,
                  onTap: () => onChoose(places[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    super.key,
    required this.place,
    required this.icon,
    required this.onTap,
  });

  final Place place;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detail = <String>[
      if (place.region != null) place.region!,
      if (place.countryCode != null) place.countryCode!,
    ].join(', ');
    return ListTile(
      onTap: onTap,
      minTileHeight: OsmonSize.tapTarget + OsmonSpace.s8,
      leading: Icon(
        icon,
        size: OsmonSize.iconMd,
        color: OsmonColors.textSecondary,
      ),
      title: Text(place.name, style: OsmonType.bodyStrong),
      subtitle: detail.isEmpty
          ? null
          : Text(
              detail,
              style: OsmonType.caption.copyWith(
                color: OsmonColors.textTertiary,
              ),
            ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) => ShimmerScope(
    child: Padding(
      padding: const EdgeInsets.only(top: OsmonSpace.s24),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < 5; i++) ...<Widget>[
            const SkeletonBlock(height: OsmonSize.tapTarget + OsmonSpace.s8),
            const SizedBox(height: OsmonSpace.s8),
          ],
        ],
      ),
    ),
  );
}
