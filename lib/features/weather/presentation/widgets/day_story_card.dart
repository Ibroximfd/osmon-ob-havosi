import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/format/formats.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../domain/services/day_story.dart';

/// The AI's day plan when available, otherwise the offline rule-based one —
/// so the card always says something useful, in every language.
class DayStoryCard extends StatelessWidget {
  const DayStoryCard({
    super.key,
    required this.story,
    required this.aiText,
    required this.formats,
    required this.tint,
  });

  final DayStory story;
  final String? aiText;
  final Formats formats;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = aiText != null
        ? <String>[aiText!]
        : <String>[
            for (final line in story.lines) _line(l10n, line),
            if (story.bestHour != null)
              l10n.storyBestHour(formats.hour(story.bestHour!)),
          ];
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                aiText != null ? LucideIcons.sparkles : LucideIcons.calendar,
                size: OsmonSize.iconSm,
                color: tint,
              ),
              const SizedBox(width: OsmonSpace.s8),
              Text(
                (aiText != null ? l10n.storyAiLabel : l10n.storyLocalLabel)
                    .toUpperCase(),
                style: OsmonType.eyebrow,
              ),
            ],
          ),
          const SizedBox(height: OsmonSpace.s10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: OsmonSpace.s6),
              child: Text(line, style: OsmonType.body.copyWith(height: 1.55)),
            ),
        ],
      ),
    );
  }

  String _line(AppLocalizations l10n, StoryLine line) {
    final hour = line.hour == null ? '' : formats.hour(line.hour!);
    final value = line.value ?? 0;
    return switch (line.topic) {
      StoryTopic.umbrella => l10n.storyUmbrella(hour, formats.percent(value)),
      StoryTopic.snowAndIce => l10n.storySnowIce,
      StoryTopic.storm => l10n.storyStorm(hour),
      StoryTopic.heat => l10n.storyHeat(formats.temperature(value)),
      StoryTopic.cold => l10n.storyCold(formats.temperature(value)),
      StoryTopic.layers => l10n.storyLayers(formats.temperature(value)),
      StoryTopic.strongUv => l10n.storyStrongUv(value.round().toString()),
      StoryTopic.wind => l10n.storyWind(hour, formats.wind(value)),
      StoryTopic.badAir => l10n.storyBadAir(value.round().toString()),
      StoryTopic.fogMorning => l10n.storyFogMorning,
      StoryTopic.calm => l10n.storyCalm,
    };
  }
}
