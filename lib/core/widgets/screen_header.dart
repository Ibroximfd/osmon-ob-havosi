import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';
import 'osmon_button.dart';

/// Title block at the top of a screen; pushed screens get a back button.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: OsmonSpace.s8, bottom: OsmonSpace.s4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (showBack) ...<Widget>[
          OsmonIconButton(
            icon: LucideIcons.arrowLeft,
            tooltip: context.l10n.actionBack,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: OsmonSpace.s12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(title, style: OsmonType.titleLarge),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: OsmonSpace.s2),
                  child: Text(
                    subtitle!,
                    style: OsmonType.caption.copyWith(
                      color: OsmonColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
