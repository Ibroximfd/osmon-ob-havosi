import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/severity_pill.dart';
import '../../domain/air_quality.dart';
import '../../domain/health_assessment.dart';

String aqiLabel(AppLocalizations l10n, AqiCategory category) =>
    switch (category) {
      AqiCategory.good => l10n.aqiGood,
      AqiCategory.moderate => l10n.aqiModerate,
      AqiCategory.unhealthyForSensitive => l10n.aqiSensitive,
      AqiCategory.unhealthy => l10n.aqiUnhealthy,
      AqiCategory.veryUnhealthy => l10n.aqiVeryUnhealthy,
      AqiCategory.hazardous => l10n.aqiHazardous,
    };

String aqiAdvice(AppLocalizations l10n, AqiCategory category) =>
    switch (category) {
      AqiCategory.good => l10n.aqiAdviceGood,
      AqiCategory.moderate => l10n.aqiAdviceModerate,
      AqiCategory.unhealthyForSensitive => l10n.aqiAdviceSensitive,
      AqiCategory.unhealthy => l10n.aqiAdviceUnhealthy,
      AqiCategory.veryUnhealthy ||
      AqiCategory.hazardous => l10n.aqiAdviceVeryUnhealthy,
    };

Severity aqiSeverity(AqiCategory category) => switch (category) {
  AqiCategory.good => Severity.good,
  AqiCategory.moderate => Severity.moderate,
  AqiCategory.unhealthyForSensitive => Severity.elevated,
  AqiCategory.unhealthy => Severity.severe,
  AqiCategory.veryUnhealthy || AqiCategory.hazardous => Severity.extreme,
};

String pollenTypeLabel(AppLocalizations l10n, PollenType type) =>
    switch (type) {
      PollenType.alder => l10n.pollenAlder,
      PollenType.birch => l10n.pollenBirch,
      PollenType.grass => l10n.pollenGrass,
      PollenType.mugwort => l10n.pollenMugwort,
      PollenType.olive => l10n.pollenOlive,
      PollenType.ragweed => l10n.pollenRagweed,
    };

String allergenLabel(AppLocalizations l10n, SeasonalAllergen allergen) =>
    switch (allergen) {
      SeasonalAllergen.trees => l10n.allergenTrees,
      SeasonalAllergen.grasses => l10n.allergenGrasses,
      SeasonalAllergen.wormwood => l10n.allergenWormwood,
      SeasonalAllergen.goosefoot => l10n.allergenGoosefoot,
      SeasonalAllergen.ragweed => l10n.allergenRagweed,
    };

(Severity, String) pollenLevelBadge(AppLocalizations l10n, PollenLevel level) =>
    switch (level) {
      PollenLevel.none => (Severity.good, l10n.pollenNone),
      PollenLevel.low => (Severity.good, l10n.severityLow),
      PollenLevel.moderate => (Severity.moderate, l10n.severityModerate),
      PollenLevel.high => (Severity.severe, l10n.severityHigh),
    };
