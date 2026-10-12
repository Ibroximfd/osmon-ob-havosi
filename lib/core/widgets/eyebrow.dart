import 'package:flutter/widgets.dart';

import '../theme/osmon_spacing.dart';
import '../theme/osmon_typography.dart';

/// Uppercase section label above a group of cards.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.trailing, this.padding});

  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding:
        padding ??
        const EdgeInsets.only(top: OsmonSpace.s20, bottom: OsmonSpace.s8),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              text.toUpperCase(),
              style: OsmonType.eyebrow,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
