import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ky'),
    Locale('ru'),
    Locale('tg'),
    Locale('uz'),
  ];

  /// No description provided for @actionAllow.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get actionAllow;

  /// No description provided for @actionBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get actionBack;

  /// No description provided for @actionCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get actionClear;

  /// No description provided for @actionClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get actionClose;

  /// No description provided for @actionContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get actionContinue;

  /// No description provided for @actionDone.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get actionDone;

  /// No description provided for @actionLater.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get actionLater;

  /// No description provided for @actionOpenSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni ochish'**
  String get actionOpenSettings;

  /// No description provided for @actionRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get actionSave;

  /// No description provided for @actionSearch.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get actionSearch;

  /// No description provided for @actionShare.
  ///
  /// In uz, this message translates to:
  /// **'Ulashish'**
  String get actionShare;

  /// No description provided for @actionSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get actionSkip;

  /// No description provided for @actionUpdate.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get actionUpdate;

  /// No description provided for @adLabel.
  ///
  /// In uz, this message translates to:
  /// **'Reklama'**
  String get adLabel;

  /// No description provided for @alertAdviceDust.
  ///
  /// In uz, this message translates to:
  /// **'Derazalarni yoping, ko\'chaga niqob bilan chiqing.'**
  String get alertAdviceDust;

  /// No description provided for @alertAdviceFrost.
  ///
  /// In uz, this message translates to:
  /// **'Suv quvurlari va ko\'chatlarni himoyalang.'**
  String get alertAdviceFrost;

  /// No description provided for @alertAdviceHail.
  ///
  /// In uz, this message translates to:
  /// **'Mashinani yopiq joyga qo\'ying, ekinlarni himoyalang.'**
  String get alertAdviceHail;

  /// No description provided for @alertAdviceHeat.
  ///
  /// In uz, this message translates to:
  /// **'12:00–17:00 da tashqarida ishlamang, ko\'p suv iching.'**
  String get alertAdviceHeat;

  /// No description provided for @alertAdviceHeavyRain.
  ///
  /// In uz, this message translates to:
  /// **'Past joylarda suv toshqini xavfi — ariq va soylardan uzoq turing.'**
  String get alertAdviceHeavyRain;

  /// No description provided for @alertAdviceSnow.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'llar yopilishi mumkin — safarni kechiktiring.'**
  String get alertAdviceSnow;

  /// No description provided for @alertAdviceThunderstorm.
  ///
  /// In uz, this message translates to:
  /// **'Ochiq joyda va daraxt tagida turmang.'**
  String get alertAdviceThunderstorm;

  /// No description provided for @alertAdviceWind.
  ///
  /// In uz, this message translates to:
  /// **'Reklama taxtalari va daraxtlardan uzoq yuring.'**
  String get alertAdviceWind;

  /// No description provided for @alertKindDust.
  ///
  /// In uz, this message translates to:
  /// **'Chang bo\'roni'**
  String get alertKindDust;

  /// No description provided for @alertKindFrost.
  ///
  /// In uz, this message translates to:
  /// **'Qattiq sovuq'**
  String get alertKindFrost;

  /// No description provided for @alertKindHail.
  ///
  /// In uz, this message translates to:
  /// **'Do\'l'**
  String get alertKindHail;

  /// No description provided for @alertKindHeat.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli issiq'**
  String get alertKindHeat;

  /// No description provided for @alertKindHeavyRain.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli yomg\'ir'**
  String get alertKindHeavyRain;

  /// No description provided for @alertKindSnow.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli qor'**
  String get alertKindSnow;

  /// No description provided for @alertKindThunderstorm.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq'**
  String get alertKindThunderstorm;

  /// No description provided for @alertKindWind.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli shamol'**
  String get alertKindWind;

  /// No description provided for @alertOrange.
  ///
  /// In uz, this message translates to:
  /// **'To\'q sariq'**
  String get alertOrange;

  /// No description provided for @alertRed.
  ///
  /// In uz, this message translates to:
  /// **'Qizil'**
  String get alertRed;

  /// No description provided for @alertYellow.
  ///
  /// In uz, this message translates to:
  /// **'Sariq'**
  String get alertYellow;

  /// No description provided for @alertsEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin 3 kunda viloyatlarda ogohlantirish yo\'q.'**
  String get alertsEmptyMessage;

  /// No description provided for @alertsEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xavfli ob-havo kutilmaydi'**
  String get alertsEmptyTitle;

  /// No description provided for @alertsRegions.
  ///
  /// In uz, this message translates to:
  /// **'Viloyatlar bo\'yicha'**
  String get alertsRegions;

  /// No description provided for @alertsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekiston viloyatlari · 3 kun'**
  String get alertsSubtitle;

  /// No description provided for @alertsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ogohlantirishlar'**
  String get alertsTitle;

  /// No description provided for @alertsYourPlace.
  ///
  /// In uz, this message translates to:
  /// **'Sizning joyingiz'**
  String get alertsYourPlace;

  /// No description provided for @allergenGoosefoot.
  ///
  /// In uz, this message translates to:
  /// **'Sho\'ra va olabuta'**
  String get allergenGoosefoot;

  /// No description provided for @allergenGrasses.
  ///
  /// In uz, this message translates to:
  /// **'Boshoqli o\'tlar'**
  String get allergenGrasses;

  /// No description provided for @allergenRagweed.
  ///
  /// In uz, this message translates to:
  /// **'Ambroziya'**
  String get allergenRagweed;

  /// No description provided for @allergenTrees.
  ///
  /// In uz, this message translates to:
  /// **'Daraxtlar: terak, qayrag\'och, chinor'**
  String get allergenTrees;

  /// No description provided for @allergenWormwood.
  ///
  /// In uz, this message translates to:
  /// **'Shuvoq'**
  String get allergenWormwood;

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'Osmon'**
  String get appName;

  /// No description provided for @aqiAdviceGood.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'chada bemalol bo\'lish mumkin.'**
  String get aqiAdviceGood;

  /// No description provided for @aqiAdviceModerate.
  ///
  /// In uz, this message translates to:
  /// **'Sezgir odamlar uzoq mashg\'ulotni kamaytirsin.'**
  String get aqiAdviceModerate;

  /// No description provided for @aqiAdviceSensitive.
  ///
  /// In uz, this message translates to:
  /// **'Astma va yurak kasalligi borlar ko\'chada kam bo\'lsin.'**
  String get aqiAdviceSensitive;

  /// No description provided for @aqiAdviceUnhealthy.
  ///
  /// In uz, this message translates to:
  /// **'Hamma uchun zararli — derazalarni yoping, niqob taqing.'**
  String get aqiAdviceUnhealthy;

  /// No description provided for @aqiAdviceVeryUnhealthy.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'chaga chiqmang, havo tozalagichdan foydalaning.'**
  String get aqiAdviceVeryUnhealthy;

  /// No description provided for @aqiGood.
  ///
  /// In uz, this message translates to:
  /// **'Yaxshi'**
  String get aqiGood;

  /// No description provided for @aqiHazardous.
  ///
  /// In uz, this message translates to:
  /// **'Xavfli'**
  String get aqiHazardous;

  /// No description provided for @aqiModerate.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha'**
  String get aqiModerate;

  /// No description provided for @aqiSensitive.
  ///
  /// In uz, this message translates to:
  /// **'Sezgirlar uchun zararli'**
  String get aqiSensitive;

  /// No description provided for @aqiUnhealthy.
  ///
  /// In uz, this message translates to:
  /// **'Zararli'**
  String get aqiUnhealthy;

  /// No description provided for @aqiVeryUnhealthy.
  ///
  /// In uz, this message translates to:
  /// **'Juda zararli'**
  String get aqiVeryUnhealthy;

  /// No description provided for @blueHour.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'k soat'**
  String get blueHour;

  /// No description provided for @chatDisclaimer.
  ///
  /// In uz, this message translates to:
  /// **'AI xato qilishi mumkin — muhim qarorlarni prognoz bilan tekshiring.'**
  String get chatDisclaimer;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Javoblar joriy prognozga asoslanadi.'**
  String get chatEmptyMessage;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havo haqida so\'rang'**
  String get chatEmptyTitle;

  /// No description provided for @chatError.
  ///
  /// In uz, this message translates to:
  /// **'Javob kelmadi.'**
  String get chatError;

  /// No description provided for @chatHint.
  ///
  /// In uz, this message translates to:
  /// **'Savolingizni yozing…'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get chatSend;

  /// No description provided for @chatSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havo bo\'yicha savollaringizga javob'**
  String get chatSubtitle;

  /// No description provided for @chatSuggest1.
  ///
  /// In uz, this message translates to:
  /// **'Bugun nima kiyay?'**
  String get chatSuggest1;

  /// No description provided for @chatSuggest2.
  ///
  /// In uz, this message translates to:
  /// **'Kechqurun yomg\'ir yog\'adimi?'**
  String get chatSuggest2;

  /// No description provided for @chatSuggest3.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga yugurish uchun eng yaxshi vaqt?'**
  String get chatSuggest3;

  /// No description provided for @chatSuggest4.
  ///
  /// In uz, this message translates to:
  /// **'Dam olish kunlari sayrga chiqsa bo\'ladimi?'**
  String get chatSuggest4;

  /// No description provided for @chatTitle.
  ///
  /// In uz, this message translates to:
  /// **'Osmon AI'**
  String get chatTitle;

  /// No description provided for @chatTyping.
  ///
  /// In uz, this message translates to:
  /// **'Yozmoqda…'**
  String get chatTyping;

  /// No description provided for @conditionClear.
  ///
  /// In uz, this message translates to:
  /// **'Ochiq osmon'**
  String get conditionClear;

  /// No description provided for @conditionDrizzle.
  ///
  /// In uz, this message translates to:
  /// **'Mayda yomg\'ir'**
  String get conditionDrizzle;

  /// No description provided for @conditionFog.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get conditionFog;

  /// No description provided for @conditionFreezingDrizzle.
  ///
  /// In uz, this message translates to:
  /// **'Muzlovchi mayda yomg\'ir'**
  String get conditionFreezingDrizzle;

  /// No description provided for @conditionFreezingRain.
  ///
  /// In uz, this message translates to:
  /// **'Muzli yomg\'ir'**
  String get conditionFreezingRain;

  /// No description provided for @conditionHeavyRain.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli yomg\'ir'**
  String get conditionHeavyRain;

  /// No description provided for @conditionHeavySnow.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli qor'**
  String get conditionHeavySnow;

  /// No description provided for @conditionMainlyClear.
  ///
  /// In uz, this message translates to:
  /// **'Asosan ochiq'**
  String get conditionMainlyClear;

  /// No description provided for @conditionOvercast.
  ///
  /// In uz, this message translates to:
  /// **'Bulutli'**
  String get conditionOvercast;

  /// No description provided for @conditionPartlyCloudy.
  ///
  /// In uz, this message translates to:
  /// **'Qisman bulutli'**
  String get conditionPartlyCloudy;

  /// No description provided for @conditionRain.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir'**
  String get conditionRain;

  /// No description provided for @conditionRainShowers.
  ///
  /// In uz, this message translates to:
  /// **'Jala'**
  String get conditionRainShowers;

  /// No description provided for @conditionSnow.
  ///
  /// In uz, this message translates to:
  /// **'Qor'**
  String get conditionSnow;

  /// No description provided for @conditionSnowShowers.
  ///
  /// In uz, this message translates to:
  /// **'Qor yog\'ishi'**
  String get conditionSnowShowers;

  /// No description provided for @conditionThunderstorm.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq'**
  String get conditionThunderstorm;

  /// No description provided for @conditionThunderstormHail.
  ///
  /// In uz, this message translates to:
  /// **'Do\'l bilan momaqaldiroq'**
  String get conditionThunderstormHail;

  /// No description provided for @cropCotton.
  ///
  /// In uz, this message translates to:
  /// **'Paxta'**
  String get cropCotton;

  /// No description provided for @cropGrape.
  ///
  /// In uz, this message translates to:
  /// **'Uzum'**
  String get cropGrape;

  /// No description provided for @cropOrchard.
  ///
  /// In uz, this message translates to:
  /// **'Bog\''**
  String get cropOrchard;

  /// No description provided for @cropVegetables.
  ///
  /// In uz, this message translates to:
  /// **'Sabzavot'**
  String get cropVegetables;

  /// No description provided for @cropWheat.
  ///
  /// In uz, this message translates to:
  /// **'Bug\'doy'**
  String get cropWheat;

  /// No description provided for @dataAttribution.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot: Open-Meteo'**
  String get dataAttribution;

  /// No description provided for @dateDayMonth.
  ///
  /// In uz, this message translates to:
  /// **'{day}-{month}'**
  String dateDayMonth(String day, String month);

  /// No description provided for @daySheetChance.
  ///
  /// In uz, this message translates to:
  /// **'Ehtimol {value}'**
  String daySheetChance(String value);

  /// No description provided for @daySheetGusts.
  ///
  /// In uz, this message translates to:
  /// **'Shamol shiddati {value}'**
  String daySheetGusts(String value);

  /// No description provided for @daySheetPrecip.
  ///
  /// In uz, this message translates to:
  /// **'Yog\'in {value} mm'**
  String daySheetPrecip(String value);

  /// No description provided for @daySheetSun.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh {rise} – {set}'**
  String daySheetSun(String rise, String set);

  /// No description provided for @daySheetUv.
  ///
  /// In uz, this message translates to:
  /// **'UV {value}'**
  String daySheetUv(String value);

  /// No description provided for @daylightLength.
  ///
  /// In uz, this message translates to:
  /// **'Kun uzunligi {duration}'**
  String daylightLength(String duration);

  /// No description provided for @departIn1h.
  ///
  /// In uz, this message translates to:
  /// **'1 soatdan keyin'**
  String get departIn1h;

  /// No description provided for @departIn2h.
  ///
  /// In uz, this message translates to:
  /// **'2 soatdan keyin'**
  String get departIn2h;

  /// No description provided for @departIn4h.
  ///
  /// In uz, this message translates to:
  /// **'4 soatdan keyin'**
  String get departIn4h;

  /// No description provided for @departNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir'**
  String get departNow;

  /// No description provided for @departTomorrow.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga 07:00'**
  String get departTomorrow;

  /// No description provided for @dewPoint.
  ///
  /// In uz, this message translates to:
  /// **'Shudring nuqtasi {temp}'**
  String dewPoint(String temp);

  /// No description provided for @durationHours.
  ///
  /// In uz, this message translates to:
  /// **'{hours} soat'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In uz, this message translates to:
  /// **'{hours} soat {minutes} daq'**
  String durationHoursMinutes(String hours, String minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqa'**
  String durationMinutes(int minutes);

  /// No description provided for @evening.
  ///
  /// In uz, this message translates to:
  /// **'Kechqurun'**
  String get evening;

  /// No description provided for @fieldAdvice.
  ///
  /// In uz, this message translates to:
  /// **'Tavsiyalar'**
  String get fieldAdvice;

  /// No description provided for @fieldDisclaimer.
  ///
  /// In uz, this message translates to:
  /// **'Tavsiyalar ob-havo modeliga asoslangan; muhim qarorlarda agronom bilan maslahatlashing.'**
  String get fieldDisclaimer;

  /// No description provided for @fieldEt0.
  ///
  /// In uz, this message translates to:
  /// **'Bug\'lanish (ET0)'**
  String get fieldEt0;

  /// No description provided for @fieldEt0Caption.
  ///
  /// In uz, this message translates to:
  /// **'mm/kun · bugun'**
  String get fieldEt0Caption;

  /// No description provided for @fieldFrostAdvice.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'chatlarni yoping, kechqurun sug\'oring — nam tuproq issiqni saqlaydi.'**
  String get fieldFrostAdvice;

  /// No description provided for @fieldFrostDetail.
  ///
  /// In uz, this message translates to:
  /// **'Eng sovuq tun: {date} · {temp}'**
  String fieldFrostDetail(String date, String temp);

  /// No description provided for @fieldFrostTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tungi sovuq xavfi'**
  String get fieldFrostTitle;

  /// No description provided for @fieldGdd.
  ///
  /// In uz, this message translates to:
  /// **'Faol harorat yig\'indisi'**
  String get fieldGdd;

  /// No description provided for @fieldGddCaption.
  ///
  /// In uz, this message translates to:
  /// **'1-martdan beri · baza {base}'**
  String fieldGddCaption(String base);

  /// No description provided for @fieldGddNone.
  ///
  /// In uz, this message translates to:
  /// **'Mavsum 1-martdan boshlanadi'**
  String get fieldGddNone;

  /// No description provided for @fieldSoilMoisture.
  ///
  /// In uz, this message translates to:
  /// **'Tuproq namligi'**
  String get fieldSoilMoisture;

  /// No description provided for @fieldSoilTemp.
  ///
  /// In uz, this message translates to:
  /// **'Tuproq harorati'**
  String get fieldSoilTemp;

  /// No description provided for @fieldSoilTempCaption.
  ///
  /// In uz, this message translates to:
  /// **'6 sm chuqurlikda · yuzasi {surface}'**
  String fieldSoilTempCaption(String surface);

  /// No description provided for @fieldTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dala rejimi'**
  String get fieldTitle;

  /// No description provided for @frostLikely.
  ///
  /// In uz, this message translates to:
  /// **'Xavf yuqori'**
  String get frostLikely;

  /// No description provided for @frostNone.
  ///
  /// In uz, this message translates to:
  /// **'Xavf yo\'q'**
  String get frostNone;

  /// No description provided for @frostPossible.
  ///
  /// In uz, this message translates to:
  /// **'Ehtimol bor'**
  String get frostPossible;

  /// No description provided for @goldenHour.
  ///
  /// In uz, this message translates to:
  /// **'Oltin soat'**
  String get goldenHour;

  /// No description provided for @harvestClear.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin 5 kunda kuchli yog\'in kutilmaydi.'**
  String get harvestClear;

  /// No description provided for @harvestWarning.
  ///
  /// In uz, this message translates to:
  /// **'{day} yog\'in ehtimoli {chance} — yig\'im-terimni oldinroq rejalang.'**
  String harvestWarning(String day, String chance);

  /// No description provided for @hazardFog.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get hazardFog;

  /// No description provided for @hazardHeavyRain.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli yomg\'ir'**
  String get hazardHeavyRain;

  /// No description provided for @hazardIce.
  ///
  /// In uz, this message translates to:
  /// **'Muz, sirpanchiq'**
  String get hazardIce;

  /// No description provided for @hazardSnow.
  ///
  /// In uz, this message translates to:
  /// **'Qor'**
  String get hazardSnow;

  /// No description provided for @hazardStorm.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq'**
  String get hazardStorm;

  /// No description provided for @hazardWind.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli shamol'**
  String get hazardWind;

  /// No description provided for @healthAqiTitle.
  ///
  /// In uz, this message translates to:
  /// **'Havo sifati (AQI)'**
  String get healthAqiTitle;

  /// No description provided for @healthBreathing.
  ///
  /// In uz, this message translates to:
  /// **'Nafas yo\'llari'**
  String get healthBreathing;

  /// No description provided for @healthDisclaimer.
  ///
  /// In uz, this message translates to:
  /// **'Bu tibbiy maslahat emas. Kasallik bo\'lsa shifokoringizga murojaat qiling.'**
  String get healthDisclaimer;

  /// No description provided for @healthDust.
  ///
  /// In uz, this message translates to:
  /// **'Chang'**
  String get healthDust;

  /// No description provided for @healthHeat.
  ///
  /// In uz, this message translates to:
  /// **'Issiqlik zarbasi'**
  String get healthHeat;

  /// No description provided for @healthMigraine.
  ///
  /// In uz, this message translates to:
  /// **'Migren xavfi'**
  String get healthMigraine;

  /// No description provided for @healthPollenMeasured.
  ///
  /// In uz, this message translates to:
  /// **'Model qiymatlari · CAMS'**
  String get healthPollenMeasured;

  /// No description provided for @healthPollenNoData.
  ///
  /// In uz, this message translates to:
  /// **'Bu hudud uchun gulchang ma\'lumoti yo\'q.'**
  String get healthPollenNoData;

  /// No description provided for @healthPollenSeasonal.
  ///
  /// In uz, this message translates to:
  /// **'Mavsumiy taqvim · O\'rta Osiyo uchun taxmin'**
  String get healthPollenSeasonal;

  /// No description provided for @healthPollenTitle.
  ///
  /// In uz, this message translates to:
  /// **'Gulchang'**
  String get healthPollenTitle;

  /// No description provided for @healthPressureTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bosim va o\'zini his qilish'**
  String get healthPressureTitle;

  /// No description provided for @healthSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'{place} · havo, gulchang va bosim'**
  String healthSubtitle(String place);

  /// No description provided for @healthTitle.
  ///
  /// In uz, this message translates to:
  /// **'Salomatlik'**
  String get healthTitle;

  /// No description provided for @healthUvSkin.
  ///
  /// In uz, this message translates to:
  /// **'Teri uchun UV'**
  String get healthUvSkin;

  /// No description provided for @heatCaution.
  ///
  /// In uz, this message translates to:
  /// **'Ehtiyot bo\'ling'**
  String get heatCaution;

  /// No description provided for @heatDanger.
  ///
  /// In uz, this message translates to:
  /// **'Xavfli'**
  String get heatDanger;

  /// No description provided for @heatNone.
  ///
  /// In uz, this message translates to:
  /// **'Xavf yo\'q'**
  String get heatNone;

  /// No description provided for @homeChatTooltip.
  ///
  /// In uz, this message translates to:
  /// **'Osmon AI bilan suhbat'**
  String get homeChatTooltip;

  /// No description provided for @homeCurrentLocation.
  ///
  /// In uz, this message translates to:
  /// **'Joriy joylashuv'**
  String get homeCurrentLocation;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvingizni aniqlang yoki shaharni qidiring.'**
  String get homeEmptyMessage;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi shahar ob-havosini ko\'rsatay?'**
  String get homeEmptyTitle;

  /// No description provided for @homeFavoriteAdd.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilarga qo\'shish'**
  String get homeFavoriteAdd;

  /// No description provided for @homeFavoriteRemove.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilardan olib tashlash'**
  String get homeFavoriteRemove;

  /// No description provided for @homeFeelsLike.
  ///
  /// In uz, this message translates to:
  /// **'His qilinadi {temp}'**
  String homeFeelsLike(String temp);

  /// No description provided for @homeLocateAction.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvni aniqlash'**
  String get homeLocateAction;

  /// No description provided for @homeLocationAction.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get homeLocationAction;

  /// No description provided for @homeLocationBlockedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Telefon sozlamalaridan ruxsat bering. Hozir {city} ko\'rsatilmoqda.'**
  String homeLocationBlockedMessage(String city);

  /// No description provided for @homeLocationDeniedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvga ruxsat yo\'q'**
  String get homeLocationDeniedTitle;

  /// No description provided for @homeLocationMessage.
  ///
  /// In uz, this message translates to:
  /// **'Aniq ob-havo uchun yoqing. Hozir {city} ko\'rsatilmoqda.'**
  String homeLocationMessage(String city);

  /// No description provided for @homeLocationOffTitle.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv o\'chiq'**
  String get homeLocationOffTitle;

  /// No description provided for @homeRouteHint.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lning har bir qismi uchun prognoz'**
  String get homeRouteHint;

  /// No description provided for @homeSearchTooltip.
  ///
  /// In uz, this message translates to:
  /// **'Shahar qidirish'**
  String get homeSearchTooltip;

  /// No description provided for @indexCarWash.
  ///
  /// In uz, this message translates to:
  /// **'Mashina yuvish'**
  String get indexCarWash;

  /// No description provided for @indexCycling.
  ///
  /// In uz, this message translates to:
  /// **'Velosiped'**
  String get indexCycling;

  /// No description provided for @indexLaundry.
  ///
  /// In uz, this message translates to:
  /// **'Kir quritish'**
  String get indexLaundry;

  /// No description provided for @indexRunning.
  ///
  /// In uz, this message translates to:
  /// **'Yugurish'**
  String get indexRunning;

  /// No description provided for @indexStargazing.
  ///
  /// In uz, this message translates to:
  /// **'Yulduz kuzatish'**
  String get indexStargazing;

  /// No description provided for @indexWalking.
  ///
  /// In uz, this message translates to:
  /// **'Sayr'**
  String get indexWalking;

  /// No description provided for @intensityHeavy.
  ///
  /// In uz, this message translates to:
  /// **'kuchli'**
  String get intensityHeavy;

  /// No description provided for @intensityLight.
  ///
  /// In uz, this message translates to:
  /// **'kuchsiz'**
  String get intensityLight;

  /// No description provided for @intensityModerate.
  ///
  /// In uz, this message translates to:
  /// **'o\'rtacha'**
  String get intensityModerate;

  /// No description provided for @irrigationDetail.
  ///
  /// In uz, this message translates to:
  /// **'3 kunda ~{mm} mm suv kerak (≈ {volume} m³/ga) · kutilayotgan yog\'in {rain} mm'**
  String irrigationDetail(String mm, String volume, String rain);

  /// No description provided for @irrigationNotNeeded.
  ///
  /// In uz, this message translates to:
  /// **'Sug\'orish shart emas'**
  String get irrigationNotNeeded;

  /// No description provided for @irrigationNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir sug\'oring'**
  String get irrigationNow;

  /// No description provided for @irrigationSoon.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin kunlarda sug\'oring'**
  String get irrigationSoon;

  /// No description provided for @lastYearColder.
  ///
  /// In uz, this message translates to:
  /// **'O\'tgan yilgi shu kundan {delta} sovuq'**
  String lastYearColder(String delta);

  /// No description provided for @lastYearSame.
  ///
  /// In uz, this message translates to:
  /// **'O\'tgan yilgi shu kun bilan deyarli bir xil'**
  String get lastYearSame;

  /// No description provided for @lastYearWarmer.
  ///
  /// In uz, this message translates to:
  /// **'O\'tgan yilgi shu kundan {delta} issiq'**
  String lastYearWarmer(String delta);

  /// No description provided for @layerAirQuality.
  ///
  /// In uz, this message translates to:
  /// **'Havo sifati'**
  String get layerAirQuality;

  /// No description provided for @layerClouds.
  ///
  /// In uz, this message translates to:
  /// **'Bulutlar'**
  String get layerClouds;

  /// No description provided for @layerPrecipitation.
  ///
  /// In uz, this message translates to:
  /// **'Yog\'in'**
  String get layerPrecipitation;

  /// No description provided for @layerTemperature.
  ///
  /// In uz, this message translates to:
  /// **'Harorat'**
  String get layerTemperature;

  /// No description provided for @layerWind.
  ///
  /// In uz, this message translates to:
  /// **'Shamol'**
  String get layerWind;

  /// No description provided for @legendHigh.
  ///
  /// In uz, this message translates to:
  /// **'yuqori'**
  String get legendHigh;

  /// No description provided for @legendLow.
  ///
  /// In uz, this message translates to:
  /// **'past'**
  String get legendLow;

  /// No description provided for @mapGridFailed.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havo qatlami yuklanmadi'**
  String get mapGridFailed;

  /// No description provided for @mapMyPlace.
  ///
  /// In uz, this message translates to:
  /// **'Mening joyim'**
  String get mapMyPlace;

  /// No description provided for @mapTilesUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Xarita foni yuklanmadi — ob-havo qatlami ishlayveradi'**
  String get mapTilesUnavailable;

  /// No description provided for @mapTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havo xaritasi'**
  String get mapTitle;

  /// No description provided for @mapZoomIn.
  ///
  /// In uz, this message translates to:
  /// **'Yaqinlashtirish'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In uz, this message translates to:
  /// **'Uzoqlashtirish'**
  String get mapZoomOut;

  /// No description provided for @methodIsna.
  ///
  /// In uz, this message translates to:
  /// **'Shimoliy Amerika (ISNA)'**
  String get methodIsna;

  /// No description provided for @methodKarachi.
  ///
  /// In uz, this message translates to:
  /// **'Karachi universiteti'**
  String get methodKarachi;

  /// No description provided for @methodMwl.
  ///
  /// In uz, this message translates to:
  /// **'Musulmon olami ligasi'**
  String get methodMwl;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In uz, this message translates to:
  /// **'Ummul Quro (Makka)'**
  String get methodUmmAlQura;

  /// No description provided for @methodUzbekistan.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekiston musulmonlari idorasi'**
  String get methodUzbekistan;

  /// No description provided for @metricHumidity.
  ///
  /// In uz, this message translates to:
  /// **'Namlik'**
  String get metricHumidity;

  /// No description provided for @metricPressure.
  ///
  /// In uz, this message translates to:
  /// **'Bosim'**
  String get metricPressure;

  /// No description provided for @metricSun.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh'**
  String get metricSun;

  /// No description provided for @metricUv.
  ///
  /// In uz, this message translates to:
  /// **'UV indeks'**
  String get metricUv;

  /// No description provided for @metricVisibility.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get metricVisibility;

  /// No description provided for @metricWind.
  ///
  /// In uz, this message translates to:
  /// **'Shamol'**
  String get metricWind;

  /// No description provided for @moistureDry.
  ///
  /// In uz, this message translates to:
  /// **'Quruq'**
  String get moistureDry;

  /// No description provided for @moistureOk.
  ///
  /// In uz, this message translates to:
  /// **'Yetarli'**
  String get moistureOk;

  /// No description provided for @month1.
  ///
  /// In uz, this message translates to:
  /// **'yanvar'**
  String get month1;

  /// No description provided for @month10.
  ///
  /// In uz, this message translates to:
  /// **'oktabr'**
  String get month10;

  /// No description provided for @month11.
  ///
  /// In uz, this message translates to:
  /// **'noyabr'**
  String get month11;

  /// No description provided for @month12.
  ///
  /// In uz, this message translates to:
  /// **'dekabr'**
  String get month12;

  /// No description provided for @month2.
  ///
  /// In uz, this message translates to:
  /// **'fevral'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In uz, this message translates to:
  /// **'mart'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In uz, this message translates to:
  /// **'aprel'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In uz, this message translates to:
  /// **'may'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In uz, this message translates to:
  /// **'iyun'**
  String get month6;

  /// No description provided for @month7.
  ///
  /// In uz, this message translates to:
  /// **'iyul'**
  String get month7;

  /// No description provided for @month8.
  ///
  /// In uz, this message translates to:
  /// **'avgust'**
  String get month8;

  /// No description provided for @month9.
  ///
  /// In uz, this message translates to:
  /// **'sentabr'**
  String get month9;

  /// No description provided for @moonFirstQuarter.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi chorak'**
  String get moonFirstQuarter;

  /// No description provided for @moonFull.
  ///
  /// In uz, this message translates to:
  /// **'To\'lin oy'**
  String get moonFull;

  /// No description provided for @moonIllumination.
  ///
  /// In uz, this message translates to:
  /// **'Yoritilgan qismi {value}'**
  String moonIllumination(String value);

  /// No description provided for @moonLastQuarter.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi chorak'**
  String get moonLastQuarter;

  /// No description provided for @moonNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi oy'**
  String get moonNew;

  /// No description provided for @moonTitle.
  ///
  /// In uz, this message translates to:
  /// **'Oy fazasi'**
  String get moonTitle;

  /// No description provided for @moonWaningCrescent.
  ///
  /// In uz, this message translates to:
  /// **'Kamayuvchi hilol'**
  String get moonWaningCrescent;

  /// No description provided for @moonWaningGibbous.
  ///
  /// In uz, this message translates to:
  /// **'Kamayuvchi oy'**
  String get moonWaningGibbous;

  /// No description provided for @moonWaxingCrescent.
  ///
  /// In uz, this message translates to:
  /// **'O\'suvchi hilol'**
  String get moonWaxingCrescent;

  /// No description provided for @moonWaxingGibbous.
  ///
  /// In uz, this message translates to:
  /// **'O\'suvchi oy'**
  String get moonWaxingGibbous;

  /// No description provided for @morning.
  ///
  /// In uz, this message translates to:
  /// **'Ertalab'**
  String get morning;

  /// No description provided for @navHealth.
  ///
  /// In uz, this message translates to:
  /// **'Salomatlik'**
  String get navHealth;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In uz, this message translates to:
  /// **'Xarita'**
  String get navMap;

  /// No description provided for @navRadar.
  ///
  /// In uz, this message translates to:
  /// **'Radar'**
  String get navRadar;

  /// No description provided for @navSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlama'**
  String get navSettings;

  /// No description provided for @notifBlockedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Telefon ilovaga bildirishnoma yuborishni taqiqlagan, shuning uchun ogohlantirishlar kelmaydi.'**
  String get notifBlockedMessage;

  /// No description provided for @notifBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar o\'chiq'**
  String get notifBlockedTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In uz, this message translates to:
  /// **'Bugun {min}…{max}. Yog\'in ehtimoli {chance}.'**
  String notifDailyBody(String min, String max, String chance);

  /// No description provided for @notifDailyTitle.
  ///
  /// In uz, this message translates to:
  /// **'{city}: {condition}'**
  String notifDailyTitle(String city, String condition);

  /// No description provided for @notifDustBody.
  ///
  /// In uz, this message translates to:
  /// **'{city}: derazalarni yoping, ko\'chaga niqob bilan chiqing.'**
  String notifDustBody(String city);

  /// No description provided for @notifDustTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chang bo\'roni'**
  String get notifDustTitle;

  /// No description provided for @notifFrostBody.
  ///
  /// In uz, this message translates to:
  /// **'{city}: ko\'chatlarni yoping, suv quvurlarini himoya qiling.'**
  String notifFrostBody(String city);

  /// No description provided for @notifFrostTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kechasi sovuq: {temp}'**
  String notifFrostTitle(String temp);

  /// No description provided for @notifKindDaily.
  ///
  /// In uz, this message translates to:
  /// **'Ertalabki prognoz (07:00)'**
  String get notifKindDaily;

  /// No description provided for @notifKindPrayer.
  ///
  /// In uz, this message translates to:
  /// **'Namoz vaqti eslatmasi'**
  String get notifKindPrayer;

  /// No description provided for @notifPrayerBody.
  ///
  /// In uz, this message translates to:
  /// **'{city} · {time}'**
  String notifPrayerBody(String city, String time);

  /// No description provided for @notifPrayerTitle.
  ///
  /// In uz, this message translates to:
  /// **'{prayer} vaqti kirdi'**
  String notifPrayerTitle(String prayer);

  /// No description provided for @notifRainBody.
  ///
  /// In uz, this message translates to:
  /// **'{city}: soyabonni oling va kirni yig\'ib qo\'ying.'**
  String notifRainBody(String city);

  /// No description provided for @notifRainTitle.
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqadan keyin yomg\'ir'**
  String notifRainTitle(int minutes);

  /// No description provided for @notifSnowTitle.
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqadan keyin qor'**
  String notifSnowTitle(int minutes);

  /// No description provided for @notifStormBody.
  ///
  /// In uz, this message translates to:
  /// **'{city}, {time} atrofida. Ochiq joyda va daraxt tagida turmang.'**
  String notifStormBody(String city, String time);

  /// No description provided for @notifStormTitle.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq kutilmoqda'**
  String get notifStormTitle;

  /// No description provided for @onbFeatureLifeBody.
  ///
  /// In uz, this message translates to:
  /// **'Havo sifati, sovuq xavfi va yo\'ldagi ob-havo bir joyda.'**
  String get onbFeatureLifeBody;

  /// No description provided for @onbFeatureLifeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Salomatlik, dala va yo\'l'**
  String get onbFeatureLifeTitle;

  /// No description provided for @onbFeatureNowcastBody.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir qachon boshlanib, qachon tinishini oldindan bilasiz.'**
  String get onbFeatureNowcastBody;

  /// No description provided for @onbFeatureNowcastTitle.
  ///
  /// In uz, this message translates to:
  /// **'Daqiqalik yomg\'ir'**
  String get onbFeatureNowcastTitle;

  /// No description provided for @onbFeaturePrayerBody.
  ///
  /// In uz, this message translates to:
  /// **'Internetsiz ham aniq hisoblanadi.'**
  String get onbFeaturePrayerBody;

  /// No description provided for @onbFeaturePrayerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Namoz vaqtlari va quyosh yo\'li'**
  String get onbFeaturePrayerTitle;

  /// No description provided for @onbFeaturesSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ekranda haqiqiy osmon, cho\'ntakda foydali javoblar.'**
  String get onbFeaturesSubtitle;

  /// No description provided for @onbFeaturesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Osmon — tirik ob-havo'**
  String get onbFeaturesTitle;

  /// No description provided for @onbGranted.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berildi'**
  String get onbGranted;

  /// No description provided for @onbLanguageSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvingizga qarab tanladik — xohlasangiz o\'zgartiring.'**
  String get onbLanguageSubtitle;

  /// No description provided for @onbLanguageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get onbLanguageTitle;

  /// No description provided for @onbLocationBody.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havoni aynan siz turgan joy uchun ko\'rsatamiz.'**
  String get onbLocationBody;

  /// No description provided for @onbLocationDenied.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berilmadi — shaharni keyin qo\'lda tanlaysiz.'**
  String get onbLocationDenied;

  /// No description provided for @onbLocationServicesOff.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv o\'chiq — yoqsangiz, ob-havo turgan joyingizga moslashadi.'**
  String get onbLocationServicesOff;

  /// No description provided for @onbLocationTitle.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv'**
  String get onbLocationTitle;

  /// No description provided for @onbNotifBody.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir, momaqaldiroq va sovuqdan oldindan ogohlantiramiz.'**
  String get onbNotifBody;

  /// No description provided for @onbNotifTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get onbNotifTitle;

  /// No description provided for @onbPermissionsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ikkalasini ham keyinroq sozlamalardan o\'zgartirish mumkin.'**
  String get onbPermissionsSubtitle;

  /// No description provided for @onbPermissionsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ikki kichik ruxsat'**
  String get onbPermissionsTitle;

  /// No description provided for @onbStart.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get onbStart;

  /// No description provided for @outlookDry.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin 2 soatda yog\'in kutilmaydi'**
  String get outlookDry;

  /// No description provided for @outlookDrySubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Radar bo\'yicha · har 15 daqiqada yangilanadi'**
  String get outlookDrySubtitle;

  /// No description provided for @outlookDustBody.
  ///
  /// In uz, this message translates to:
  /// **'Havo sifati {aqi}. Ko\'chaga niqob bilan chiqing.'**
  String outlookDustBody(String aqi);

  /// No description provided for @outlookEndsIn.
  ///
  /// In uz, this message translates to:
  /// **'Tinishiga {duration} qoldi · {intensity}'**
  String outlookEndsIn(String duration, String intensity);

  /// No description provided for @outlookLasts.
  ///
  /// In uz, this message translates to:
  /// **'{duration} davom etadi · {intensity}'**
  String outlookLasts(String duration, String intensity);

  /// No description provided for @outlookLastsLong.
  ///
  /// In uz, this message translates to:
  /// **'Uzoq davom etadi · {intensity}'**
  String outlookLastsLong(String intensity);

  /// No description provided for @outlookRainAhead.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir {minutes} daqiqadan keyin'**
  String outlookRainAhead(int minutes);

  /// No description provided for @outlookRainNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir yomg\'ir yog\'yapti'**
  String get outlookRainNow;

  /// No description provided for @outlookSnowAhead.
  ///
  /// In uz, this message translates to:
  /// **'Qor {minutes} daqiqadan keyin'**
  String outlookSnowAhead(int minutes);

  /// No description provided for @outlookSnowNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir qor yog\'yapti'**
  String get outlookSnowNow;

  /// No description provided for @permissionNotificationsDenied.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalarga ruxsat berilmagan. Telefon sozlamalaridan yoqing.'**
  String get permissionNotificationsDenied;

  /// No description provided for @photoAnalyse.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havoni tahlil qilish'**
  String get photoAnalyse;

  /// No description provided for @photoAnalysis.
  ///
  /// In uz, this message translates to:
  /// **'Tahlil'**
  String get photoAnalysis;

  /// No description provided for @photoCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamera'**
  String get photoCamera;

  /// No description provided for @photoEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Osmon, bulut yoki ko\'cha rasmi eng yaxshi natija beradi.'**
  String get photoEmptyMessage;

  /// No description provided for @photoEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Rasm tanlang'**
  String get photoEmptyTitle;

  /// No description provided for @photoGallery.
  ///
  /// In uz, this message translates to:
  /// **'Galereya'**
  String get photoGallery;

  /// No description provided for @photoNew.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa rasm'**
  String get photoNew;

  /// No description provided for @photoPermissionDenied.
  ///
  /// In uz, this message translates to:
  /// **'Galereyaga saqlashga ruxsat berilmadi.'**
  String get photoPermissionDenied;

  /// No description provided for @photoRestyle.
  ///
  /// In uz, this message translates to:
  /// **'Ob-havoni o\'zgartirish'**
  String get photoRestyle;

  /// No description provided for @photoSave.
  ///
  /// In uz, this message translates to:
  /// **'Galereyaga saqlash'**
  String get photoSave;

  /// No description provided for @photoSaved.
  ///
  /// In uz, this message translates to:
  /// **'Rasm galereyaga saqlandi'**
  String get photoSaved;

  /// No description provided for @photoStyleClear.
  ///
  /// In uz, this message translates to:
  /// **'Musaffo'**
  String get photoStyleClear;

  /// No description provided for @photoStyleRain.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'irli'**
  String get photoStyleRain;

  /// No description provided for @photoStyleSnow.
  ///
  /// In uz, this message translates to:
  /// **'Qorli'**
  String get photoStyleSnow;

  /// No description provided for @photoStyleStorm.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq'**
  String get photoStyleStorm;

  /// No description provided for @photoStyleSunset.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh botishi'**
  String get photoStyleSunset;

  /// No description provided for @photoSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Osmon rasmini yuklang — AI uni tahlil qiladi yoki ob-havoni o\'zgartiradi'**
  String get photoSubtitle;

  /// No description provided for @photoTitle.
  ///
  /// In uz, this message translates to:
  /// **'AI Foto'**
  String get photoTitle;

  /// No description provided for @pollenAlder.
  ///
  /// In uz, this message translates to:
  /// **'Olxa'**
  String get pollenAlder;

  /// No description provided for @pollenBirch.
  ///
  /// In uz, this message translates to:
  /// **'Qayin'**
  String get pollenBirch;

  /// No description provided for @pollenGrass.
  ///
  /// In uz, this message translates to:
  /// **'O\'t o\'simliklari'**
  String get pollenGrass;

  /// No description provided for @pollenMugwort.
  ///
  /// In uz, this message translates to:
  /// **'Shuvoq'**
  String get pollenMugwort;

  /// No description provided for @pollenNone.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get pollenNone;

  /// No description provided for @pollenOlive.
  ///
  /// In uz, this message translates to:
  /// **'Zaytun'**
  String get pollenOlive;

  /// No description provided for @pollenRagweed.
  ///
  /// In uz, this message translates to:
  /// **'Ambroziya'**
  String get pollenRagweed;

  /// No description provided for @prayerAsr.
  ///
  /// In uz, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In uz, this message translates to:
  /// **'Peshin'**
  String get prayerDhuhr;

  /// No description provided for @prayerFajr.
  ///
  /// In uz, this message translates to:
  /// **'Bomdod'**
  String get prayerFajr;

  /// No description provided for @prayerIsha.
  ///
  /// In uz, this message translates to:
  /// **'Xufton'**
  String get prayerIsha;

  /// No description provided for @prayerMaghrib.
  ///
  /// In uz, this message translates to:
  /// **'Shom'**
  String get prayerMaghrib;

  /// No description provided for @prayerMethodLine.
  ///
  /// In uz, this message translates to:
  /// **'Hisob: {method}'**
  String prayerMethodLine(String method);

  /// No description provided for @prayerNext.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi namoz'**
  String get prayerNext;

  /// No description provided for @prayerRemaining.
  ///
  /// In uz, this message translates to:
  /// **'{duration} qoldi'**
  String prayerRemaining(String duration);

  /// No description provided for @prayerSunrise.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh'**
  String get prayerSunrise;

  /// No description provided for @prayerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Namoz vaqtlari'**
  String get prayerTitle;

  /// No description provided for @pressureFalling.
  ///
  /// In uz, this message translates to:
  /// **'Pasaymoqda · 24 soatda {delta}'**
  String pressureFalling(String delta);

  /// No description provided for @pressureRising.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'tarilmoqda · 24 soatda {delta}'**
  String pressureRising(String delta);

  /// No description provided for @pressureSteady.
  ///
  /// In uz, this message translates to:
  /// **'Barqaror'**
  String get pressureSteady;

  /// No description provided for @quickAlerts.
  ///
  /// In uz, this message translates to:
  /// **'Ogohlantirishlar'**
  String get quickAlerts;

  /// No description provided for @quickChat.
  ///
  /// In uz, this message translates to:
  /// **'AI suhbat'**
  String get quickChat;

  /// No description provided for @quickField.
  ///
  /// In uz, this message translates to:
  /// **'Dala rejimi'**
  String get quickField;

  /// No description provided for @quickPhoto.
  ///
  /// In uz, this message translates to:
  /// **'AI Foto'**
  String get quickPhoto;

  /// No description provided for @quickRoute.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'l ob-havosi'**
  String get quickRoute;

  /// No description provided for @radarAlertDust.
  ///
  /// In uz, this message translates to:
  /// **'Chang bo\'roni'**
  String get radarAlertDust;

  /// No description provided for @radarAlertFrost.
  ///
  /// In uz, this message translates to:
  /// **'Tungi sovuq'**
  String get radarAlertFrost;

  /// No description provided for @radarAlertRain.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir boshlanishidan oldin'**
  String get radarAlertRain;

  /// No description provided for @radarAlertSevere.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq va do\'l'**
  String get radarAlertSevere;

  /// No description provided for @radarAlerts.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get radarAlerts;

  /// No description provided for @radarModelNote.
  ///
  /// In uz, this message translates to:
  /// **'Model prognozi asosida, har 15 daqiqada: Open-Meteo'**
  String get radarModelNote;

  /// No description provided for @radarNext2h.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi 2 soat'**
  String get radarNext2h;

  /// No description provided for @radarPause.
  ///
  /// In uz, this message translates to:
  /// **'To\'xtatish'**
  String get radarPause;

  /// No description provided for @radarPeak.
  ///
  /// In uz, this message translates to:
  /// **'Eng kuchli payt {time} · {rate} mm/soat'**
  String radarPeak(String time, String rate);

  /// No description provided for @radarPlay.
  ///
  /// In uz, this message translates to:
  /// **'Ijro etish'**
  String get radarPlay;

  /// No description provided for @radarSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'{place} · keyingi 2 soat'**
  String radarSubtitle(String place);

  /// No description provided for @radarTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yog\'in radari'**
  String get radarTitle;

  /// No description provided for @ratingFair.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In uz, this message translates to:
  /// **'Qulay'**
  String get ratingGood;

  /// No description provided for @ratingPoor.
  ///
  /// In uz, this message translates to:
  /// **'Noqulay'**
  String get ratingPoor;

  /// No description provided for @reasonBadAir.
  ///
  /// In uz, this message translates to:
  /// **'Havo ifloslangan'**
  String get reasonBadAir;

  /// No description provided for @reasonClearSky.
  ///
  /// In uz, this message translates to:
  /// **'Osmon ochiq'**
  String get reasonClearSky;

  /// No description provided for @reasonCloudy.
  ///
  /// In uz, this message translates to:
  /// **'Bulut qalin'**
  String get reasonCloudy;

  /// No description provided for @reasonDryDaysAhead.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin 2 kun quruq'**
  String get reasonDryDaysAhead;

  /// No description provided for @reasonDusty.
  ///
  /// In uz, this message translates to:
  /// **'Chang ko\'tarilgan'**
  String get reasonDusty;

  /// No description provided for @reasonFreezing.
  ///
  /// In uz, this message translates to:
  /// **'Suv muzlaydi'**
  String get reasonFreezing;

  /// No description provided for @reasonGoodDrying.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh va shamol tez quritadi'**
  String get reasonGoodDrying;

  /// No description provided for @reasonPleasant.
  ///
  /// In uz, this message translates to:
  /// **'Havo yoqimli'**
  String get reasonPleasant;

  /// No description provided for @reasonRainExpected.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir ehtimoli bor'**
  String get reasonRainExpected;

  /// No description provided for @reasonSomeClouds.
  ///
  /// In uz, this message translates to:
  /// **'Qisman bulut'**
  String get reasonSomeClouds;

  /// No description provided for @reasonStormy.
  ///
  /// In uz, this message translates to:
  /// **'Momaqaldiroq'**
  String get reasonStormy;

  /// No description provided for @reasonTooCold.
  ///
  /// In uz, this message translates to:
  /// **'Juda sovuq'**
  String get reasonTooCold;

  /// No description provided for @reasonTooHot.
  ///
  /// In uz, this message translates to:
  /// **'Juda issiq'**
  String get reasonTooHot;

  /// No description provided for @reasonTooHumid.
  ///
  /// In uz, this message translates to:
  /// **'Havo juda nam'**
  String get reasonTooHumid;

  /// No description provided for @reasonWet.
  ///
  /// In uz, this message translates to:
  /// **'Yog\'in ehtimoli'**
  String get reasonWet;

  /// No description provided for @reasonWindy.
  ///
  /// In uz, this message translates to:
  /// **'Kuchli shamol'**
  String get reasonWindy;

  /// No description provided for @relativeInMinutes.
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqadan keyin'**
  String relativeInMinutes(int minutes);

  /// No description provided for @relativeNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir'**
  String get relativeNow;

  /// No description provided for @routeAlong.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'l bo\'ylab'**
  String get routeAlong;

  /// No description provided for @routeChoose.
  ///
  /// In uz, this message translates to:
  /// **'Shaharni tanlang'**
  String get routeChoose;

  /// No description provided for @routeClear.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'l bo\'ylab xavfli hodisa kutilmaydi.'**
  String get routeClear;

  /// No description provided for @routeDelayAdvice.
  ///
  /// In uz, this message translates to:
  /// **'Chiqishni {duration} kechiktirsangiz, xavfli hodisalardan qochasiz.'**
  String routeDelayAdvice(String duration);

  /// No description provided for @routeDeparture.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash vaqti'**
  String get routeDeparture;

  /// No description provided for @routeEmptyMessage.
  ///
  /// In uz, this message translates to:
  /// **'Ikki shaharni tanlang — yo\'lning har bir qismi uchun ob-havoni ko\'rsatamiz.'**
  String get routeEmptyMessage;

  /// No description provided for @routeEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qayerga ketyapsiz?'**
  String get routeEmptyTitle;

  /// No description provided for @routeEstimated.
  ///
  /// In uz, this message translates to:
  /// **'Taxminiy yo\'nalish — yo\'l xizmati javob bermadi'**
  String get routeEstimated;

  /// No description provided for @routeFrom.
  ///
  /// In uz, this message translates to:
  /// **'Qayerdan'**
  String get routeFrom;

  /// No description provided for @routeHazardsAhead.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lda xavfli hodisalar bor — ehtiyot bo\'ling.'**
  String get routeHazardsAhead;

  /// No description provided for @routeKm.
  ///
  /// In uz, this message translates to:
  /// **'{km}-km'**
  String routeKm(String km);

  /// No description provided for @routeSave.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalishni saqlash'**
  String get routeSave;

  /// No description provided for @routeSaved.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan yo\'nalishlar'**
  String get routeSaved;

  /// No description provided for @routeSummary.
  ///
  /// In uz, this message translates to:
  /// **'{distance} km · {duration}'**
  String routeSummary(String distance, String duration);

  /// No description provided for @routeSwap.
  ///
  /// In uz, this message translates to:
  /// **'Almashtirish'**
  String get routeSwap;

  /// No description provided for @routeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'l ob-havosi'**
  String get routeTitle;

  /// No description provided for @routeTo.
  ///
  /// In uz, this message translates to:
  /// **'Qayerga'**
  String get routeTo;

  /// No description provided for @routeUnsave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlanganlardan olib tashlash'**
  String get routeUnsave;

  /// No description provided for @searchFavorites.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilar'**
  String get searchFavorites;

  /// No description provided for @searchHint.
  ///
  /// In uz, this message translates to:
  /// **'Shahar yoki tuman nomi'**
  String get searchHint;

  /// No description provided for @searchNoResultsMessage.
  ///
  /// In uz, this message translates to:
  /// **'Boshqacha yozib ko\'ring: lotin yoki kirill harflarida.'**
  String get searchNoResultsMessage;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In uz, this message translates to:
  /// **'“{query}” topilmadi'**
  String searchNoResultsTitle(String query);

  /// No description provided for @searchRegional.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat markazlari'**
  String get searchRegional;

  /// No description provided for @searchResults.
  ///
  /// In uz, this message translates to:
  /// **'Natijalar'**
  String get searchResults;

  /// No description provided for @searchTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shahar tanlash'**
  String get searchTitle;

  /// No description provided for @searchUseLocation.
  ///
  /// In uz, this message translates to:
  /// **'Joriy joylashuvim'**
  String get searchUseLocation;

  /// No description provided for @sectionDaily.
  ///
  /// In uz, this message translates to:
  /// **'10 kunlik prognoz'**
  String get sectionDaily;

  /// No description provided for @sectionHourly.
  ///
  /// In uz, this message translates to:
  /// **'Soatlik prognoz'**
  String get sectionHourly;

  /// No description provided for @sectionIndices.
  ///
  /// In uz, this message translates to:
  /// **'Bugun nima qilsa bo\'ladi'**
  String get sectionIndices;

  /// No description provided for @sectionNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozirgi holat'**
  String get sectionNow;

  /// No description provided for @sectionQuick.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'limlar'**
  String get sectionQuick;

  /// No description provided for @sensitivityHigh.
  ///
  /// In uz, this message translates to:
  /// **'Bosim keskin o\'zgarmoqda — migren va bo\'g\'im og\'rig\'i xavfi yuqori.'**
  String get sensitivityHigh;

  /// No description provided for @sensitivityLow.
  ///
  /// In uz, this message translates to:
  /// **'Bosim barqaror — meteo-sezgir odamlar uchun qulay kun.'**
  String get sensitivityLow;

  /// No description provided for @sensitivityModerate.
  ///
  /// In uz, this message translates to:
  /// **'Bosim o\'zgarmoqda — bosh og\'rig\'i bo\'lishi mumkin.'**
  String get sensitivityModerate;

  /// No description provided for @settingsAbout.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get settingsAbout;

  /// No description provided for @settingsAdPrivacy.
  ///
  /// In uz, this message translates to:
  /// **'Reklama va maxfiylik sozlamalari'**
  String get settingsAdPrivacy;

  /// No description provided for @settingsAppearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get settingsAppearance;

  /// No description provided for @settingsBatterySaver.
  ///
  /// In uz, this message translates to:
  /// **'Batareyani tejash'**
  String get settingsBatterySaver;

  /// No description provided for @settingsBatterySaverHint.
  ///
  /// In uz, this message translates to:
  /// **'Kamroq zarracha va 30 kadr/s'**
  String get settingsBatterySaverHint;

  /// No description provided for @settingsDataSources.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar: Open-Meteo · Xarita: OpenFreeMap, OpenStreetMap · Yo\'nalish: OSRM'**
  String get settingsDataSources;

  /// No description provided for @settingsLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi ochilishda joylashuvingizga qarab tanlangan.'**
  String get settingsLanguageHint;

  /// No description provided for @settingsLiveBackground.
  ///
  /// In uz, this message translates to:
  /// **'Jonli osmon foni'**
  String get settingsLiveBackground;

  /// No description provided for @settingsLiveBackgroundHint.
  ///
  /// In uz, this message translates to:
  /// **'Fon haqiqiy ob-havo bilan birga harakatlanadi'**
  String get settingsLiveBackgroundHint;

  /// No description provided for @settingsNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get settingsNotifications;

  /// No description provided for @settingsPrayerMethod.
  ///
  /// In uz, this message translates to:
  /// **'Namoz vaqtlari hisobi'**
  String get settingsPrayerMethod;

  /// No description provided for @settingsPrayerMethodHint.
  ///
  /// In uz, this message translates to:
  /// **'Asr — hanafiy mazhabi bo\'yicha'**
  String get settingsPrayerMethodHint;

  /// No description provided for @settingsPressure.
  ///
  /// In uz, this message translates to:
  /// **'Bosim'**
  String get settingsPressure;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsRate.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani baholash'**
  String get settingsRate;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In uz, this message translates to:
  /// **'Harakatni kamaytirish'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In uz, this message translates to:
  /// **'Fon to\'xtaydi, animatsiyalar kamayadi'**
  String get settingsReduceMotionHint;

  /// No description provided for @settingsTemperature.
  ///
  /// In uz, this message translates to:
  /// **'Harorat'**
  String get settingsTemperature;

  /// No description provided for @settingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsTitle;

  /// No description provided for @settingsUnits.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchov birliklari'**
  String get settingsUnits;

  /// No description provided for @settingsVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsWind.
  ///
  /// In uz, this message translates to:
  /// **'Shamol tezligi'**
  String get settingsWind;

  /// No description provided for @severityHigh.
  ///
  /// In uz, this message translates to:
  /// **'Yuqori'**
  String get severityHigh;

  /// No description provided for @severityLow.
  ///
  /// In uz, this message translates to:
  /// **'Past'**
  String get severityLow;

  /// No description provided for @severityModerate.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha'**
  String get severityModerate;

  /// No description provided for @severityVeryHigh.
  ///
  /// In uz, this message translates to:
  /// **'Juda yuqori'**
  String get severityVeryHigh;

  /// No description provided for @sprayHint.
  ///
  /// In uz, this message translates to:
  /// **'Shamol 12 km/soatdan kam, 3 soat yog\'insiz'**
  String get sprayHint;

  /// No description provided for @sprayNone.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin 3 kunda qulay oyna yo\'q — shamol yoki yog\'in xalaqit beradi.'**
  String get sprayNone;

  /// No description provided for @sprayTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dori purkash oynasi'**
  String get sprayTitle;

  /// No description provided for @sprayWindow.
  ///
  /// In uz, this message translates to:
  /// **'{day}, {start}–{end}'**
  String sprayWindow(String day, String start, String end);

  /// No description provided for @stateErrorMessage.
  ///
  /// In uz, this message translates to:
  /// **'Server javob bermadi. Birozdan keyin qayta urinib ko\'ring.'**
  String get stateErrorMessage;

  /// No description provided for @stateErrorTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot yuklanmadi'**
  String get stateErrorTitle;

  /// No description provided for @stateLoading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda'**
  String get stateLoading;

  /// No description provided for @stateNotConfiguredMessage.
  ///
  /// In uz, this message translates to:
  /// **'Bu funksiya keyingi yangilanishda ishga tushadi.'**
  String get stateNotConfiguredMessage;

  /// No description provided for @stateNotConfiguredTitle.
  ///
  /// In uz, this message translates to:
  /// **'AI hozircha o\'chirilgan'**
  String get stateNotConfiguredTitle;

  /// No description provided for @stateOfflineBanner.
  ///
  /// In uz, this message translates to:
  /// **'Internet yo\'q — oxirgi saqlangan ma\'lumot'**
  String get stateOfflineBanner;

  /// No description provided for @stateOfflineMessage.
  ///
  /// In uz, this message translates to:
  /// **'Internetga ulaning va qayta urinib ko\'ring.'**
  String get stateOfflineMessage;

  /// No description provided for @stateOfflineTitle.
  ///
  /// In uz, this message translates to:
  /// **'Internet yo\'q'**
  String get stateOfflineTitle;

  /// No description provided for @statePermissionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berilmagan'**
  String get statePermissionTitle;

  /// No description provided for @stateQuotaMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat hozir band. Bir daqiqadan keyin qayta urinib ko\'ring.'**
  String get stateQuotaMessage;

  /// No description provided for @stateUpdatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Yangilangan: {time}'**
  String stateUpdatedAt(String time);

  /// No description provided for @storyAiLabel.
  ///
  /// In uz, this message translates to:
  /// **'Osmon AI · kun rejasi'**
  String get storyAiLabel;

  /// No description provided for @storyBadAir.
  ///
  /// In uz, this message translates to:
  /// **'Havo sifati yomon ({aqi}) — sport bilan uyda shug\'ullaning.'**
  String storyBadAir(String aqi);

  /// No description provided for @storyBestHour.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'chada bo\'lish uchun eng yaxshi vaqt — {time}.'**
  String storyBestHour(String time);

  /// No description provided for @storyCalm.
  ///
  /// In uz, this message translates to:
  /// **'Kun tinch o\'tadi — maxsus ehtiyot choralari kerak emas.'**
  String get storyCalm;

  /// No description provided for @storyCold.
  ///
  /// In uz, this message translates to:
  /// **'{temp} gacha sovuq — qalin kiyining, qo\'lqop oling.'**
  String storyCold(String temp);

  /// No description provided for @storyFogMorning.
  ///
  /// In uz, this message translates to:
  /// **'Ertalab tuman — haydovchilar ehtiyot bo\'lsin.'**
  String get storyFogMorning;

  /// No description provided for @storyHeat.
  ///
  /// In uz, this message translates to:
  /// **'Kunduzi {temp} gacha isiydi — 12:00–16:00 da soyada yuring, ko\'p suv iching.'**
  String storyHeat(String temp);

  /// No description provided for @storyLayers.
  ///
  /// In uz, this message translates to:
  /// **'Ertalab {temp}, kunduzi iliq — qatlamli kiyining.'**
  String storyLayers(String temp);

  /// No description provided for @storyLocalLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kun rejasi'**
  String get storyLocalLabel;

  /// No description provided for @storySnowIce.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'llar sirpanchiq bo\'lishi mumkin — ehtiyot bo\'ling va issiq kiying.'**
  String get storySnowIce;

  /// No description provided for @storyStorm.
  ///
  /// In uz, this message translates to:
  /// **'{time} atrofida momaqaldiroq — ochiq joyda qolmang.'**
  String storyStorm(String time);

  /// No description provided for @storyStrongUv.
  ///
  /// In uz, this message translates to:
  /// **'UV indeks {value} — krem va ko\'zoynak kerak.'**
  String storyStrongUv(String value);

  /// No description provided for @storyUmbrella.
  ///
  /// In uz, this message translates to:
  /// **'{time} atrofida yomg\'ir ehtimoli {chance} — soyabonni oling.'**
  String storyUmbrella(String time, String chance);

  /// No description provided for @storyWind.
  ///
  /// In uz, this message translates to:
  /// **'{time} atrofida shamol {speed} gacha kuchayadi.'**
  String storyWind(String time, String speed);

  /// No description provided for @sunBelowHorizon.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh ufq ostida'**
  String get sunBelowHorizon;

  /// No description provided for @sunNoon.
  ///
  /// In uz, this message translates to:
  /// **'Zenit {time}'**
  String sunNoon(String time);

  /// No description provided for @sunTitle.
  ///
  /// In uz, this message translates to:
  /// **'Quyosh yo\'li'**
  String get sunTitle;

  /// No description provided for @today.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga'**
  String get tomorrow;

  /// No description provided for @tonight.
  ///
  /// In uz, this message translates to:
  /// **'Bugun kechasi'**
  String get tonight;

  /// No description provided for @unitCm.
  ///
  /// In uz, this message translates to:
  /// **'sm'**
  String get unitCm;

  /// No description provided for @unitHpa.
  ///
  /// In uz, this message translates to:
  /// **'hPa'**
  String get unitHpa;

  /// No description provided for @unitKm.
  ///
  /// In uz, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitKmh.
  ///
  /// In uz, this message translates to:
  /// **'km/soat'**
  String get unitKmh;

  /// No description provided for @unitMicrograms.
  ///
  /// In uz, this message translates to:
  /// **'mkg/m³'**
  String get unitMicrograms;

  /// No description provided for @unitMm.
  ///
  /// In uz, this message translates to:
  /// **'mm'**
  String get unitMm;

  /// No description provided for @unitMmHg.
  ///
  /// In uz, this message translates to:
  /// **'mm sim. ust.'**
  String get unitMmHg;

  /// No description provided for @unitMs.
  ///
  /// In uz, this message translates to:
  /// **'m/s'**
  String get unitMs;

  /// No description provided for @unitPercent.
  ///
  /// In uz, this message translates to:
  /// **'{value}%'**
  String unitPercent(String value);

  /// No description provided for @updateForcedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Bu versiya endi qo\'llab-quvvatlanmaydi. Davom etish uchun yangilang.'**
  String get updateForcedMessage;

  /// No description provided for @updateMessage.
  ///
  /// In uz, this message translates to:
  /// **'Yangilang — yangi funksiyalar va tezroq ishlash sizni kutmoqda.'**
  String get updateMessage;

  /// No description provided for @updateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi versiya chiqdi'**
  String get updateTitle;

  /// No description provided for @uvCaptionHigh.
  ///
  /// In uz, this message translates to:
  /// **'Tushda soyada yuring'**
  String get uvCaptionHigh;

  /// No description provided for @uvCaptionLow.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsiz'**
  String get uvCaptionLow;

  /// No description provided for @uvCaptionModerate.
  ///
  /// In uz, this message translates to:
  /// **'Krem suring'**
  String get uvCaptionModerate;

  /// No description provided for @uvCaptionVeryHigh.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'chada kam bo\'ling'**
  String get uvCaptionVeryHigh;

  /// No description provided for @visibilityGood.
  ///
  /// In uz, this message translates to:
  /// **'Yaxshi ko\'rinadi'**
  String get visibilityGood;

  /// No description provided for @visibilityKm.
  ///
  /// In uz, this message translates to:
  /// **'{km} km'**
  String visibilityKm(String km);

  /// No description provided for @visibilityPoor.
  ///
  /// In uz, this message translates to:
  /// **'Tuman, ehtiyot bo\'ling'**
  String get visibilityPoor;

  /// No description provided for @weekday1.
  ///
  /// In uz, this message translates to:
  /// **'Dushanba'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In uz, this message translates to:
  /// **'Seshanba'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In uz, this message translates to:
  /// **'Chorshanba'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In uz, this message translates to:
  /// **'Payshanba'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In uz, this message translates to:
  /// **'Juma'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In uz, this message translates to:
  /// **'Shanba'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In uz, this message translates to:
  /// **'Yakshanba'**
  String get weekday7;

  /// No description provided for @weekdayShort1.
  ///
  /// In uz, this message translates to:
  /// **'Du'**
  String get weekdayShort1;

  /// No description provided for @weekdayShort2.
  ///
  /// In uz, this message translates to:
  /// **'Se'**
  String get weekdayShort2;

  /// No description provided for @weekdayShort3.
  ///
  /// In uz, this message translates to:
  /// **'Ch'**
  String get weekdayShort3;

  /// No description provided for @weekdayShort4.
  ///
  /// In uz, this message translates to:
  /// **'Pa'**
  String get weekdayShort4;

  /// No description provided for @weekdayShort5.
  ///
  /// In uz, this message translates to:
  /// **'Ju'**
  String get weekdayShort5;

  /// No description provided for @weekdayShort6.
  ///
  /// In uz, this message translates to:
  /// **'Sh'**
  String get weekdayShort6;

  /// No description provided for @weekdayShort7.
  ///
  /// In uz, this message translates to:
  /// **'Ya'**
  String get weekdayShort7;

  /// No description provided for @widgetDry.
  ///
  /// In uz, this message translates to:
  /// **'2 soat ichida yog\'in yo\'q'**
  String get widgetDry;

  /// No description provided for @widgetRainIn.
  ///
  /// In uz, this message translates to:
  /// **'Yomg\'ir {minutes} daqiqadan keyin'**
  String widgetRainIn(String minutes);

  /// No description provided for @widgetRainNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir yog\'moqda'**
  String get widgetRainNow;

  /// No description provided for @widgetUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Yangilandi {time}'**
  String widgetUpdated(String time);

  /// No description provided for @windE.
  ///
  /// In uz, this message translates to:
  /// **'sharqdan'**
  String get windE;

  /// No description provided for @windGustsFrom.
  ///
  /// In uz, this message translates to:
  /// **'{direction}, shiddat {gusts}'**
  String windGustsFrom(String direction, String gusts);

  /// No description provided for @windN.
  ///
  /// In uz, this message translates to:
  /// **'shimoldan'**
  String get windN;

  /// No description provided for @windNE.
  ///
  /// In uz, this message translates to:
  /// **'shimoli-sharqdan'**
  String get windNE;

  /// No description provided for @windNW.
  ///
  /// In uz, this message translates to:
  /// **'shimoli-g\'arbdan'**
  String get windNW;

  /// No description provided for @windS.
  ///
  /// In uz, this message translates to:
  /// **'janubdan'**
  String get windS;

  /// No description provided for @windSE.
  ///
  /// In uz, this message translates to:
  /// **'janubi-sharqdan'**
  String get windSE;

  /// No description provided for @windSW.
  ///
  /// In uz, this message translates to:
  /// **'janubi-g\'arbdan'**
  String get windSW;

  /// No description provided for @windW.
  ///
  /// In uz, this message translates to:
  /// **'g\'arbdan'**
  String get windW;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'kk',
    'ky',
    'ru',
    'tg',
    'uz',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ky':
      return AppLocalizationsKy();
    case 'ru':
      return AppLocalizationsRu();
    case 'tg':
      return AppLocalizationsTg();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
