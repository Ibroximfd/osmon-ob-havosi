import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../error/data_failure.dart';
import '../l10n/l10n.dart';
import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';
import 'glass_panel.dart';
import 'osmon_button.dart';

/// A centred message with an icon and one action. The shared shape behind
/// the empty, no-results, error and offline states.
class MessageStateView extends StatelessWidget {
  const MessageStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor = OsmonColors.textSecondary,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: OsmonSpace.s24,
      vertical: OsmonSpace.s32,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: OsmonSize.glyphMd, color: iconColor),
        const SizedBox(height: OsmonSpace.s14),
        Text(title, style: OsmonType.titleSmall, textAlign: TextAlign.center),
        if (message != null) ...<Widget>[
          const SizedBox(height: OsmonSpace.s6),
          Text(
            message!,
            style: OsmonType.body.copyWith(color: OsmonColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
        if (actionLabel != null && onAction != null) ...<Widget>[
          const SizedBox(height: OsmonSpace.s20),
          OsmonButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}

/// Failure with a retry that re-adds the same event. Offline failures get
/// the neutral wording; rate limits say to wait.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.onRetry, this.failure});

  final VoidCallback onRetry;
  final DataFailure? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOffline = failure is OfflineFailure;
    return MessageStateView(
      icon: isOffline ? LucideIcons.wifiOff : LucideIcons.cloudOff,
      title: isOffline ? l10n.stateOfflineTitle : l10n.stateErrorTitle,
      message: switch (failure) {
        OfflineFailure() => l10n.stateOfflineMessage,
        QuotaFailure() => l10n.stateQuotaMessage,
        _ => l10n.stateErrorMessage,
      },
      actionLabel: l10n.actionRetry,
      onAction: onRetry,
    );
  }
}

/// Neutral strip shown above cached content while the device is offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.updatedAt, this.onRetry});

  /// Already-formatted time of the cached data.
  final String? updatedAt;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s14,
        vertical: OsmonSpace.s10,
      ),
      radius: OsmonRadius.md,
      onTap: onRetry,
      child: Row(
        children: <Widget>[
          const Icon(
            LucideIcons.wifiOff,
            size: OsmonSize.iconSm,
            color: OsmonColors.textSecondary,
          ),
          const SizedBox(width: OsmonSpace.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.stateOfflineBanner, style: OsmonType.captionStrong),
                if (updatedAt != null)
                  Text(
                    l10n.stateUpdatedAt(updatedAt!),
                    style: OsmonType.micro.copyWith(
                      color: OsmonColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          if (onRetry != null)
            const Icon(
              LucideIcons.refreshCw,
              size: OsmonSize.iconSm,
              color: OsmonColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

/// A compact, neutral notice row with one action — for hints that sit above
/// content rather than replacing it.
class OfflineStyleNotice extends StatelessWidget {
  const OfflineStyleNotice({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => GlassPanel(
    radius: OsmonRadius.md,
    padding: const EdgeInsets.fromLTRB(
      OsmonSpace.s14,
      OsmonSpace.s12,
      OsmonSpace.s8,
      OsmonSpace.s12,
    ),
    child: Row(
      children: <Widget>[
        Icon(icon, size: OsmonSize.iconMd, color: OsmonColors.textSecondary),
        const SizedBox(width: OsmonSpace.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: OsmonType.captionStrong),
              Text(
                message,
                style: OsmonType.micro.copyWith(
                  color: OsmonColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(foregroundColor: OsmonColors.accent),
          child: Text(actionLabel, style: OsmonType.captionStrong),
        ),
      ],
    ),
  );
}
