import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter ships no Material/Cupertino strings for Tajik. Borrow Russian —
/// the closest set Tajik readers know — so buttons, pickers and tooltips
/// never fail to resolve.
const Map<String, Locale> _borrowed = <String, Locale>{'tg': Locale('ru')};

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _borrowed.containsKey(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(
        _borrowed[locale.languageCode]!,
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _borrowed.containsKey(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(
        _borrowed[locale.languageCode]!,
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
