import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';

/// A labelled toggle row. The whole row is the tap target.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(OsmonRadius.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: OsmonSize.tapTarget),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title, style: OsmonType.body),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: OsmonType.caption.copyWith(
                        color: OsmonColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: OsmonSpace.s12),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: OsmonColors.accent,
              inactiveTrackColor: OsmonColors.glassFillStrong,
              inactiveThumbColor: OsmonColors.textSecondary,
              trackOutlineColor: const WidgetStatePropertyAll<Color>(
                OsmonColors.glassStrokeSoft,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
