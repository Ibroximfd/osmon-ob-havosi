import '../../settings/domain/app_settings.dart';

/// Countries whose people get their own language by default. Turkmenistan
/// has no Turkmen translation yet, so Russian is the closest shared one.
const Map<String, String> _languageByCountry = <String, String>{
  'UZ': 'uz',
  'KZ': 'kk',
  'KG': 'ky',
  'TJ': 'tg',
  'RU': 'ru',
  'BY': 'ru',
  'TM': 'ru',
};

/// Picks the first-launch language: the GPS country is the strongest
/// signal, then the phone's region setting, then the phone's language;
/// Uzbek when nothing is known, since that is the core audience.
String detectLanguage({
  String? gpsCountryCode,
  String? regionCountryCode,
  String? deviceLanguageCode,
}) {
  for (final country in <String?>[gpsCountryCode, regionCountryCode]) {
    final language = _languageByCountry[country?.toUpperCase()];
    if (language != null) return language;
  }
  final device = deviceLanguageCode?.toLowerCase();
  if (device != null && AppSettings.supportedLanguages.contains(device)) {
    return device;
  }
  return regionCountryCode == null && deviceLanguageCode == null ? 'uz' : 'en';
}
