import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../ads/ad_consent_manager.dart';
import '../../../../core/domain/units.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/platform/external_flow.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/osmon_chip.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/switch_row.dart';
import '../../domain/app_settings.dart';
import '../bloc/settings_bloc.dart';
import '../language_names.dart';
import 'notification_denied_listener.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: NotificationDeniedListener(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final settings = state.settings;
            final bloc = context.read<SettingsBloc>();
            return SkyScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: ScreenHeader(title: l10n.settingsTitle),
                ),
                SliverToBoxAdapter(child: Eyebrow(l10n.settingsLanguage)),
                SliverToBoxAdapter(
                  child: _LanguageList(
                    selected: settings.languageCode ?? 'uz',
                    onSelected: (code) =>
                        bloc.add(SettingsLanguageSelected(code)),
                  ),
                ),
                SliverToBoxAdapter(child: Eyebrow(l10n.settingsUnits)),
                SliverToBoxAdapter(child: _UnitsCard(settings: settings)),
                SliverToBoxAdapter(child: Eyebrow(l10n.settingsAppearance)),
                SliverToBoxAdapter(child: _AppearanceCard(settings: settings)),
                SliverToBoxAdapter(child: Eyebrow(l10n.settingsNotifications)),
                SliverToBoxAdapter(
                  child: _NotificationsCard(settings: settings),
                ),
                SliverToBoxAdapter(child: Eyebrow(l10n.settingsPrayerMethod)),
                SliverToBoxAdapter(
                  child: _PrayerMethodCard(selected: settings.prayerMethod),
                ),
                SliverToBoxAdapter(child: Eyebrow(l10n.settingsAbout)),
                const SliverToBoxAdapter(child: _AboutCard()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LanguageList extends StatelessWidget {
  const _LanguageList({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s4),
    child: Column(
      children: <Widget>[
        for (final code in AppSettings.supportedLanguages)
          _LanguageRow(
            name: languageNames[code]!,
            isSelected: code == selected,
            onTap: () => onSelected(code),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OsmonSpace.s16,
            OsmonSpace.s4,
            OsmonSpace.s16,
            OsmonSpace.s10,
          ),
          child: Text(
            context.l10n.settingsLanguageHint,
            style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
          ),
        ),
      ],
    ),
  );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    child: ListTile(
      onTap: onTap,
      title: Text(
        name,
        style: OsmonType.body.copyWith(
          color: isSelected ? OsmonColors.accent : OsmonColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              LucideIcons.check,
              size: OsmonSize.iconMd,
              color: OsmonColors.accent,
            )
          : null,
    ),
  );
}

class _UnitsCard extends StatelessWidget {
  const _UnitsCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SettingsBloc>();
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _UnitRow<TemperatureUnit>(
            title: l10n.settingsTemperature,
            values: TemperatureUnit.values,
            selected: settings.temperatureUnit,
            label: (unit) => unit == TemperatureUnit.celsius ? '°C' : '°F',
            onSelected: (unit) =>
                bloc.add(SettingsTemperatureUnitSelected(unit)),
          ),
          _UnitRow<WindUnit>(
            title: l10n.settingsWind,
            values: WindUnit.values,
            selected: settings.windUnit,
            label: (unit) =>
                unit == WindUnit.kilometresPerHour ? l10n.unitKmh : l10n.unitMs,
            onSelected: (unit) => bloc.add(SettingsWindUnitSelected(unit)),
          ),
          _UnitRow<PressureUnit>(
            title: l10n.settingsPressure,
            values: PressureUnit.values,
            selected: settings.pressureUnit,
            label: (unit) =>
                unit == PressureUnit.hectopascal ? l10n.unitHpa : l10n.unitMmHg,
            onSelected: (unit) => bloc.add(SettingsPressureUnitSelected(unit)),
          ),
        ],
      ),
    );
  }
}

class _UnitRow<T> extends StatelessWidget {
  const _UnitRow({
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s6),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(title, style: OsmonType.body)),
        Wrap(
          spacing: OsmonSpace.s6,
          children: <Widget>[
            for (final value in values)
              OsmonChip(
                label: label(value),
                selected: value == selected,
                onTap: () => onSelected(value),
              ),
          ],
        ),
      ],
    ),
  );
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SettingsBloc>();
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s14,
        vertical: OsmonSpace.s4,
      ),
      child: Column(
        children: <Widget>[
          SwitchRow(
            title: l10n.settingsLiveBackground,
            subtitle: l10n.settingsLiveBackgroundHint,
            value: settings.liveBackground,
            onChanged: (on) =>
                bloc.add(SettingsLiveBackgroundToggled(enabled: on)),
          ),
          const Divider(height: 1, color: OsmonColors.divider),
          SwitchRow(
            title: l10n.settingsBatterySaver,
            subtitle: l10n.settingsBatterySaverHint,
            value: settings.batterySaver,
            onChanged: (on) =>
                bloc.add(SettingsBatterySaverToggled(enabled: on)),
          ),
          const Divider(height: 1, color: OsmonColors.divider),
          SwitchRow(
            title: l10n.settingsReduceMotion,
            subtitle: l10n.settingsReduceMotionHint,
            value: settings.reduceMotion,
            onChanged: (on) =>
                bloc.add(SettingsReduceMotionToggled(enabled: on)),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <(NotificationKind, String)>[
      (NotificationKind.dailySummary, l10n.notifKindDaily),
      (NotificationKind.rainSoon, l10n.radarAlertRain),
      (NotificationKind.severeWeather, l10n.radarAlertSevere),
      (NotificationKind.frost, l10n.radarAlertFrost),
      (NotificationKind.dust, l10n.radarAlertDust),
      (NotificationKind.prayer, l10n.notifKindPrayer),
    ];
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: OsmonSpace.s14,
        vertical: OsmonSpace.s4,
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, color: OsmonColors.divider),
            SwitchRow(
              title: rows[i].$2,
              value: settings.isEnabled(rows[i].$1),
              onChanged: (on) => context.read<SettingsBloc>().add(
                SettingsNotificationToggled(rows[i].$1, enabled: on),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerMethodCard extends StatelessWidget {
  const _PrayerMethodCard({required this.selected});

  final PrayerMethod selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final names = <PrayerMethod, String>{
      PrayerMethod.uzbekistan: l10n.methodUzbekistan,
      PrayerMethod.muslimWorldLeague: l10n.methodMwl,
      PrayerMethod.karachi: l10n.methodKarachi,
      PrayerMethod.ummAlQura: l10n.methodUmmAlQura,
      PrayerMethod.isna: l10n.methodIsna,
    };
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s4),
      child: Column(
        children: <Widget>[
          for (final method in PrayerMethod.values)
            _LanguageRow(
              name: names[method]!,
              isSelected: method == selected,
              onTap: () => context.read<SettingsBloc>().add(
                SettingsPrayerMethodSelected(method),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OsmonSpace.s16,
              OsmonSpace.s4,
              OsmonSpace.s16,
              OsmonSpace.s10,
            ),
            child: Text(
              l10n.settingsPrayerMethodHint,
              style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatefulWidget {
  const _AboutCard();

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();
  late final Future<bool> _privacyRequired =
      AdConsentManager.instance.isPrivacyOptionsRequired;

  Future<void> _open(String url) => ExternalFlow.run(
    () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: OsmonSpace.s4),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(
              LucideIcons.shieldCheck,
              size: OsmonSize.iconMd,
            ),
            title: Text(l10n.settingsPrivacyPolicy, style: OsmonType.body),
            trailing: const Icon(
              LucideIcons.externalLink,
              size: OsmonSize.iconSm,
            ),
            onTap: () => _open(ApiEndpoints.privacyPolicy),
          ),
          FutureBuilder<bool>(
            future: _privacyRequired,
            builder: (context, snapshot) => snapshot.data == true
                ? ListTile(
                    leading: const Icon(
                      LucideIcons.slidersHorizontal,
                      size: OsmonSize.iconMd,
                    ),
                    title: Text(l10n.settingsAdPrivacy, style: OsmonType.body),
                    onTap: AdConsentManager.instance.showPrivacyOptions,
                  )
                : const SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(LucideIcons.star, size: OsmonSize.iconMd),
            title: Text(l10n.settingsRate, style: OsmonType.body),
            trailing: const Icon(
              LucideIcons.externalLink,
              size: OsmonSize.iconSm,
            ),
            onTap: () => _open(ApiEndpoints.playStore),
          ),
          FutureBuilder<PackageInfo>(
            future: _info,
            builder: (context, snapshot) => ListTile(
              leading: const Icon(LucideIcons.info, size: OsmonSize.iconMd),
              title: Text(
                l10n.settingsVersion(snapshot.data?.version ?? '…'),
                style: OsmonType.body,
              ),
              subtitle: Text(
                l10n.settingsDataSources,
                style: OsmonType.micro.copyWith(
                  color: OsmonColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
