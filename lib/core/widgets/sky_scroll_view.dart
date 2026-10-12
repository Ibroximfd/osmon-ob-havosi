import 'package:flutter/material.dart';

import '../theme/osmon_spacing.dart';

/// The scroll frame of every screen: safe-area top, side gutter, a centred
/// column capped for tablets, and room at the bottom for the floating nav.
class SkyScrollView extends StatelessWidget {
  const SkyScrollView({
    super.key,
    required this.slivers,
    this.onRefresh,
    this.clearNavBar = true,
    this.controller,
  });

  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final bool clearNavBar;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final scroll = CustomScrollView(
      controller: controller,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.only(
            top: padding.top + OsmonSpace.s8,
            bottom:
                (clearNavBar ? OsmonSize.navBarClearance : OsmonSpace.s24) +
                padding.bottom,
          ),
          sliver: SliverCenteredColumn(
            maxCrossAxisExtent: OsmonSize.maxContentWidth,
            child: SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: OsmonSpace.gutter,
              ),
              sliver: SliverMainAxisGroup(slivers: slivers),
            ),
          ),
        ),
      ],
    );
    if (onRefresh == null) return scroll;
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh!,
      edgeOffset: padding.top,
      child: scroll,
    );
  }
}

/// Centres a sliver and caps its width — the sliver counterpart of
/// `ConstrainedBox` + `Center`.
class SliverCenteredColumn extends StatelessWidget {
  const SliverCenteredColumn({
    super.key,
    required this.maxCrossAxisExtent,
    required this.child,
  });

  final double maxCrossAxisExtent;
  final Widget child;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final extra = constraints.crossAxisExtent - maxCrossAxisExtent;
      final inset = extra > 0 ? extra / 2 : 0.0;
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        sliver: child,
      );
    },
  );
}
