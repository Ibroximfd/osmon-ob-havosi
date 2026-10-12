import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Loads the bundled night style and points its labels at the field that
/// suits the app language: Latin transliterations for Uzbek and English,
/// Cyrillic names for the Cyrillic-script languages.
abstract final class MapStyle {
  static const String _asset = 'assets/map/osmon_dark_style.json';
  static const String _placeholder = '"__NAME__"';

  static final Map<String, vtr.Theme> _cache = <String, vtr.Theme>{};

  static Future<vtr.Theme> load(String languageCode) async {
    final cached = _cache[languageCode];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(_asset);
    final field = jsonEncode(_nameExpression(languageCode));
    final json = jsonDecode(raw.replaceAll(_placeholder, field));
    return _cache[languageCode] = vtr.ThemeReader().read(
      json as Map<String, dynamic>,
    );
  }

  static List<Object> _nameExpression(String languageCode) {
    final preferred = switch (languageCode) {
      'uz' || 'en' => <String>['name:latin', 'name:en'],
      'ru' || 'kk' || 'ky' || 'tg' => <String>['name:$languageCode', 'name:ru'],
      _ => <String>['name:en'],
    };
    return <Object>[
      'coalesce',
      for (final key in preferred) <String>['get', key],
      <String>['get', 'name'],
    ];
  }
}
