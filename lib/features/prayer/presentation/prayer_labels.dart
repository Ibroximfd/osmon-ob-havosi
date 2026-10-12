import '../../../core/l10n/l10n.dart';
import '../domain/prayer_day.dart';

String prayerName(AppLocalizations l10n, Prayer prayer) => switch (prayer) {
  Prayer.fajr => l10n.prayerFajr,
  Prayer.sunrise => l10n.prayerSunrise,
  Prayer.dhuhr => l10n.prayerDhuhr,
  Prayer.asr => l10n.prayerAsr,
  Prayer.maghrib => l10n.prayerMaghrib,
  Prayer.isha => l10n.prayerIsha,
};
