import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/domain/place.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/osmon_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.place,
    required this.subtitle,
    required this.isFavorite,
    required this.tint,
    required this.onSearch,
    required this.onToggleFavorite,
    required this.onChat,
  });

  final Place place;
  final String subtitle;
  final bool isFavorite;
  final Color tint;
  final VoidCallback onSearch;
  final VoidCallback onToggleFavorite;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            button: true,
            label: l10n.homeSearchTooltip,
            child: InkWell(
              onTap: onSearch,
              borderRadius: BorderRadius.circular(OsmonRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          place.isCurrentLocation
                              ? LucideIcons.navigation
                              : LucideIcons.mapPin,
                          size: OsmonSize.iconSm,
                          color: tint,
                        ),
                        const SizedBox(width: OsmonSpace.s6),
                        Flexible(
                          child: Text(
                            place.name,
                            style: OsmonType.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: OsmonSpace.s4),
                        const Icon(
                          LucideIcons.chevronDown,
                          size: OsmonSize.iconSm,
                          color: OsmonColors.textTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: OsmonSpace.s2),
                    Text(
                      subtitle,
                      style: OsmonType.micro.copyWith(
                        color: OsmonColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!place.isCurrentLocation) ...<Widget>[
          OsmonIconButton(
            icon: LucideIcons.star,
            tooltip: isFavorite
                ? l10n.homeFavoriteRemove
                : l10n.homeFavoriteAdd,
            highlighted: isFavorite,
            onPressed: onToggleFavorite,
          ),
          const SizedBox(width: OsmonSpace.s8),
        ],
        OsmonIconButton(
          icon: LucideIcons.sparkles,
          tooltip: l10n.homeChatTooltip,
          onPressed: onChat,
        ),
      ],
    );
  }
}
