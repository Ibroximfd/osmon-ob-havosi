import 'package:equatable/equatable.dart';

import '../../../core/domain/units.dart';

/// Prayer-time calculation conventions offered in settings. The default
/// matches the Muslim Board of Uzbekistan's published tables (see
/// `PrayerMethodParameters`).
enum PrayerMethod { uzbekistan, muslimWorldLeague, karachi, ummAlQura, isna }

enum NotificationKind {
  dailySummary,
  rainSoon,
  severeWeather,
  frost,
  dust,
  prayer,
}

final class AppSettings extends Equatable {
  const AppSettings({
    this.languageCode,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windUnit = WindUnit.kilometresPerHour,
    this.pressureUnit = PressureUnit.hectopascal,
    this.liveBackground = true,
    this.batterySaver = false,
    this.reduceMotion = false,
    this.prayerMethod = PrayerMethod.uzbekistan,
    // Every kind starts on; the OS permission is what really gates them.
    this.notifications = const <NotificationKind>{
      NotificationKind.dailySummary,
      NotificationKind.rainSoon,
      NotificationKind.severeWeather,
      NotificationKind.frost,
      NotificationKind.dust,
      NotificationKind.prayer,
    },
    this.onboardingDone = false,
  });

  /// `null` until the user confirms a language during onboarding; until then
  /// the detected language is used.
  final String? languageCode;
  final TemperatureUnit temperatureUnit;
  final WindUnit windUnit;
  final PressureUnit pressureUnit;
  final bool liveBackground;
  final bool batterySaver;
  final bool reduceMotion;
  final PrayerMethod prayerMethod;
  final Set<NotificationKind> notifications;
  final bool onboardingDone;

  static const List<String> supportedLanguages = <String>[
    'uz',
    'ru',
    'en',
    'kk',
    'ky',
    'tg',
  ];

  bool isEnabled(NotificationKind kind) => notifications.contains(kind);

  /// Whether the sky should actually move.
  bool get animatesSky => liveBackground && !reduceMotion;

  AppSettings copyWith({
    String? languageCode,
    TemperatureUnit? temperatureUnit,
    WindUnit? windUnit,
    PressureUnit? pressureUnit,
    bool? liveBackground,
    bool? batterySaver,
    bool? reduceMotion,
    PrayerMethod? prayerMethod,
    Set<NotificationKind>? notifications,
    bool? onboardingDone,
  }) => AppSettings(
    languageCode: languageCode ?? this.languageCode,
    temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    windUnit: windUnit ?? this.windUnit,
    pressureUnit: pressureUnit ?? this.pressureUnit,
    liveBackground: liveBackground ?? this.liveBackground,
    batterySaver: batterySaver ?? this.batterySaver,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    prayerMethod: prayerMethod ?? this.prayerMethod,
    notifications: notifications ?? this.notifications,
    onboardingDone: onboardingDone ?? this.onboardingDone,
  );

  @override
  List<Object?> get props => <Object?>[
    languageCode,
    temperatureUnit,
    windUnit,
    pressureUnit,
    liveBackground,
    batterySaver,
    reduceMotion,
    prayerMethod,
    notifications,
    onboardingDone,
  ];
}
