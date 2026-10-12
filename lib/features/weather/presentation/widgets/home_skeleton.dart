import 'package:flutter/material.dart';

import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/sky_scroll_view.dart';

/// Shaped like the loaded home screen so nothing jumps when data lands.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerScope(
    child: SkyScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SkeletonBlock(
                width: OsmonSize.skeletonLabelWidth,
                height: OsmonSpace.s20,
              ),
              SizedBox(height: OsmonSpace.s32),
              SkeletonBlock(
                width: OsmonSize.skeletonHeroWidth,
                height: OsmonSize.skeletonHeroHeight,
                radius: OsmonRadius.lg,
              ),
              SizedBox(height: OsmonSpace.s14),
              SkeletonBlock(
                width: OsmonSize.skeletonLabelWidth,
                height: OsmonSpace.s16,
              ),
              SizedBox(height: OsmonSpace.s24),
              SkeletonBlock(
                height: OsmonSize.skeletonCardHeight,
                radius: OsmonRadius.lg,
              ),
              SizedBox(height: OsmonSpace.s24),
              SkeletonBlock(
                height: OsmonSize.hourStripHeight,
                radius: OsmonRadius.lg,
              ),
              SizedBox(height: OsmonSpace.s24),
              SkeletonBlock(
                height: OsmonSize.skeletonListHeight,
                radius: OsmonRadius.lg,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
