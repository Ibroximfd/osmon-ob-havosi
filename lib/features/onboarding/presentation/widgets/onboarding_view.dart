import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_motion.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/osmon_button.dart';
import '../../../../core/widgets/reveal.dart';
import '../../../../core/widgets/weather_glyph.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/presentation/language_names.dart';
import '../bloc/onboarding_bloc.dart';

/// Three calm steps over the live sky: language, what the app does, the two
/// permissions. Finishing flips the router's redirect to home.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) => AnimatedSwitcher(
          duration: OsmonMotion.base,
          switchInCurve: OsmonMotion.emphasized,
          child: KeyedSubtree(
            key: ValueKey<OnboardingStep>(state.step),
            child: switch (state.step) {
              OnboardingStep.language => _LanguageStep(state: state),
              OnboardingStep.features => const _FeaturesStep(),
              OnboardingStep.permissions => _PermissionsStep(state: state),
            },
          ),
        ),
      ),
    ),
  );
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.action,
    this.header,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final Widget action;
  final Widget? header;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: OsmonSize.maxContentWidth),
      child: Padding(
        padding: const EdgeInsets.all(OsmonSpace.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ?header,
            Reveal(child: Text(title, style: OsmonType.titleLarge)),
            const SizedBox(height: OsmonSpace.s8),
            Reveal(
              order: 1,
              child: Text(
                subtitle,
                style: OsmonType.body.copyWith(
                  color: OsmonColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: OsmonSpace.s24),
            Expanded(child: Reveal(order: 2, child: body)),
            const SizedBox(height: OsmonSpace.s16),
            action,
          ],
        ),
      ),
    ),
  );
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<OnboardingBloc>();
    return _StepFrame(
      title: l10n.onbLanguageTitle,
      subtitle: l10n.onbLanguageSubtitle,
      body: SingleChildScrollView(
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s4),
          child: Column(
            children: <Widget>[
              for (final code in AppSettings.supportedLanguages)
                Semantics(
                  selected: code == state.language,
                  child: ListTile(
                    onTap: () => bloc.add(OnboardingLanguagePicked(code)),
                    title: Text(
                      languageNames[code]!,
                      style: OsmonType.bodyLarge.copyWith(
                        color: code == state.language
                            ? OsmonColors.accent
                            : OsmonColors.textPrimary,
                      ),
                    ),
                    trailing: code == state.language
                        ? const Icon(
                            LucideIcons.check,
                            color: OsmonColors.accent,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
      action: OsmonButton(
        label: l10n.actionContinue,
        expand: true,
        onPressed: () => bloc.add(const OnboardingStepAdvanced()),
      ),
    );
  }
}

class _FeaturesStep extends StatelessWidget {
  const _FeaturesStep();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = <(GlyphKind, String, String)>[
      (GlyphKind.rain, l10n.onbFeatureNowcastTitle, l10n.onbFeatureNowcastBody),
      (GlyphKind.moon, l10n.onbFeaturePrayerTitle, l10n.onbFeaturePrayerBody),
      (
        GlyphKind.partlyCloudyDay,
        l10n.onbFeatureLifeTitle,
        l10n.onbFeatureLifeBody,
      ),
    ];
    return _StepFrame(
      header: const Padding(
        padding: EdgeInsets.only(bottom: OsmonSpace.s24),
        child: WeatherGlyph(
          kind: GlyphKind.partlyCloudyDay,
          size: OsmonSize.glyphHero,
          animate: true,
        ),
      ),
      title: l10n.onbFeaturesTitle,
      subtitle: l10n.onbFeaturesSubtitle,
      body: ListView.separated(
        itemCount: features.length,
        separatorBuilder: (_, _) => const SizedBox(height: OsmonSpace.s10),
        itemBuilder: (context, i) => GlassPanel(
          child: Row(
            children: <Widget>[
              WeatherGlyph(kind: features[i].$1, size: OsmonSize.glyphMd),
              const SizedBox(width: OsmonSpace.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(features[i].$2, style: OsmonType.bodyStrong),
                    const SizedBox(height: OsmonSpace.s2),
                    Text(
                      features[i].$3,
                      style: OsmonType.caption.copyWith(
                        color: OsmonColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      action: OsmonButton(
        label: l10n.actionContinue,
        expand: true,
        onPressed: () =>
            context.read<OnboardingBloc>().add(const OnboardingStepAdvanced()),
      ),
    );
  }
}

class _PermissionsStep extends StatelessWidget {
  const _PermissionsStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<OnboardingBloc>();
    return _StepFrame(
      title: l10n.onbPermissionsTitle,
      subtitle: l10n.onbPermissionsSubtitle,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _PermissionCard(
              icon: LucideIcons.navigation,
              title: l10n.onbLocationTitle,
              body: state.locationFailure != null
                  ? l10n.onbLocationDenied
                  : l10n.onbLocationBody,
              granted: state.locationGranted,
              busy: state.isRequesting,
              onAllow: () => bloc.add(const OnboardingLocationRequested()),
            ),
            const SizedBox(height: OsmonSpace.s10),
            _PermissionCard(
              icon: LucideIcons.bellRing,
              title: l10n.onbNotifTitle,
              body: l10n.onbNotifBody,
              granted: state.notificationsGranted,
              busy: state.isRequesting,
              onAllow: () => bloc.add(const OnboardingNotificationsRequested()),
            ),
          ],
        ),
      ),
      action: OsmonButton(
        label: l10n.onbStart,
        expand: true,
        onPressed: () => bloc.add(const OnboardingFinished()),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.granted,
    required this.busy,
    required this.onAllow,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool granted;
  final bool busy;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: OsmonSize.iconMd, color: OsmonColors.accent),
              const SizedBox(width: OsmonSpace.s10),
              Expanded(child: Text(title, style: OsmonType.bodyStrong)),
            ],
          ),
          const SizedBox(height: OsmonSpace.s6),
          Text(
            body,
            style: OsmonType.caption.copyWith(color: OsmonColors.textSecondary),
          ),
          const SizedBox(height: OsmonSpace.s12),
          if (granted)
            Row(
              children: <Widget>[
                const Icon(
                  LucideIcons.checkCircle2,
                  size: OsmonSize.iconSm,
                  color: OsmonColors.good,
                ),
                const SizedBox(width: OsmonSpace.s6),
                Text(l10n.onbGranted, style: OsmonType.captionStrong),
              ],
            )
          else
            OsmonButton(
              label: l10n.actionAllow,
              tone: OsmonButtonTone.glass,
              isBusy: busy,
              onPressed: onAllow,
            ),
        ],
      ),
    );
  }
}
