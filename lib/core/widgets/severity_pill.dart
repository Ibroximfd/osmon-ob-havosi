import 'package:flutter/material.dart';

import '../theme/osmon_colors.dart';
import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';

enum Severity { good, moderate, elevated, severe, extreme }

extension SeverityColors on Severity {
  Color get color => switch (this) {
    Severity.good => OsmonColors.good,
    Severity.moderate => OsmonColors.moderate,
    Severity.elevated => OsmonColors.elevated,
    Severity.severe => OsmonColors.severe,
    Severity.extreme => OsmonColors.extreme,
  };
}

/// Severity always travels with a word, never colour alone.
class SeverityPill extends StatelessWidget {
  const SeverityPill({super.key, required this.severity, required this.label});

  final Severity severity;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: severity.color.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(OsmonRadius.xs),
      border: Border.all(color: severity.color.withValues(alpha: 0.5)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s8,
        vertical: OsmonSpace.s4,
      ),
      child: Text(
        label,
        style: OsmonType.micro.copyWith(
          color: Color.lerp(severity.color, OsmonColors.textPrimary, 0.45),
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
