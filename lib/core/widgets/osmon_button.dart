import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';

enum OsmonButtonTone { accent, glass }

/// Pill button. Accent for the one primary action on a screen, glass for
/// everything else. Height follows the 48 dp tap target.
class OsmonButton extends StatelessWidget {
  const OsmonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = OsmonButtonTone.accent,
    this.expand = false,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final OsmonButtonTone tone;
  final bool expand;

  /// Shows an inline spinner and ignores taps while an action runs.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final isAccent = tone == OsmonButtonTone.accent;
    final foreground = isAccent
        ? OsmonColors.textOnAccent
        : OsmonColors.textPrimary;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isBusy)
          SizedBox.square(
            dimension: OsmonSize.iconSm,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (icon != null)
          Icon(icon, size: OsmonSize.iconSm, color: foreground),
        if (isBusy || icon != null) const SizedBox(width: OsmonSpace.s8),
        Flexible(
          child: Text(
            label,
            style: OsmonType.button.copyWith(color: foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: OsmonSize.tapTarget),
      child: Material(
        color: isAccent ? OsmonColors.accent : OsmonColors.glassFillStrong,
        shape: StadiumBorder(
          side: isAccent
              ? BorderSide.none
              : const BorderSide(color: OsmonColors.glassStroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isBusy ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OsmonSpace.s20,
              vertical: OsmonSpace.s12,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Round glass icon button with a mandatory tooltip (icon-only controls
/// must be labelled for screen readers).
class OsmonIconButton extends StatelessWidget {
  const OsmonIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: highlighted ? OsmonColors.accentSoft : OsmonColors.glassFill,
      shape: const CircleBorder(
        side: BorderSide(color: OsmonColors.glassStroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: OsmonSize.tapTarget - OsmonSpace.s4,
          child: Icon(icon, size: OsmonSize.iconMd),
        ),
      ),
    ),
  );
}
