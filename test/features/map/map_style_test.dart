import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osmon_uzbekiston_ob_havosi/features/map/presentation/map_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapStyle', () {
    late int declaredLayers;

    setUpAll(() async {
      final raw = await rootBundle.loadString(
        'assets/map/osmon_dark_style.json',
      );
      declaredLayers =
          ((jsonDecode(raw) as Map<String, dynamic>)['layers'] as List<dynamic>)
              .length;
    });

    for (final language in <String>['uz', 'ru', 'en', 'kk', 'ky', 'tg']) {
      test(
        'every layer of the night style is supported for "$language"',
        () async {
          final theme = await MapStyle.load(language);

          expect(theme.id, 'osmon-night');
          // The renderer silently drops layers it cannot read; none may be.
          expect(theme.layers, hasLength(declaredLayers));
          expect(theme.tileSources, contains('openmaptiles'));
        },
      );
    }
  });
}
