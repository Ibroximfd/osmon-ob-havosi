import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/app/shell/osmon_nav_bar.dart';
import 'package:osmon_uzbekiston_ob_havosi/core/theme/osmon_colors.dart';
import 'package:osmon_uzbekiston_ob_havosi/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, {required bool overMap}) =>
    tester.pumpWidget(
      MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: OsmonNavBar(
            currentIndex: 2,
            onSelected: (_) {},
            tint: OsmonColors.accent,
            overMap: overMap,
          ),
        ),
      ),
    );

void main() {
  testWidgets('the bar blurs the sky behind it', (tester) async {
    await _pump(tester, overMap: false);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('over the moving map the bar skips the per-frame blur', (
    tester,
  ) async {
    await _pump(tester, overMap: true);
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
