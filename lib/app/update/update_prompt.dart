import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/l10n.dart';
import '../../core/platform/external_flow.dart';
import '../../core/theme/osmon_colors.dart';
import '../../core/theme/osmon_spacing.dart';
import '../../core/theme/osmon_typography.dart';
import '../../core/widgets/osmon_button.dart';
import '../di/injector.dart';
import 'update_checker.dart';

/// Checks for an app update once per launch, after the first frame.
class UpdatePrompt extends StatefulWidget {
  const UpdatePrompt({super.key, required this.child});

  final Widget child;

  @override
  State<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends State<UpdatePrompt> {
  late final UpdateChecker _checker = UpdateChecker(sl(), sl());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final offer = await _checker.check();
    if (offer == null || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: !offer.isForced,
      builder: (_) => _UpdateDialog(
        offer: offer,
        onLater: () {
          _checker.dismiss(offer);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({required this.offer, required this.onLater});

  final UpdateOffer offer;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !offer.isForced,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(OsmonSpace.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                LucideIcons.sparkles,
                size: OsmonSize.glyphMd,
                color: OsmonColors.gold,
              ),
              const SizedBox(height: OsmonSpace.s16),
              Text(
                l10n.updateTitle,
                style: OsmonType.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OsmonSpace.s8),
              Text(
                offer.isForced ? l10n.updateForcedMessage : l10n.updateMessage,
                style: OsmonType.body.copyWith(
                  color: OsmonColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OsmonSpace.s24),
              OsmonButton(
                label: l10n.actionUpdate,
                expand: true,
                onPressed: () => ExternalFlow.run(
                  () => launchUrl(
                    Uri.parse(offer.storeUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
              if (!offer.isForced) ...<Widget>[
                const SizedBox(height: OsmonSpace.s8),
                OsmonButton(
                  label: l10n.actionLater,
                  expand: true,
                  tone: OsmonButtonTone.glass,
                  onPressed: onLater,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
