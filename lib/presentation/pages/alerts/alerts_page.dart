import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/region_weather.dart';
import '../../blocs/map_bloc/map_bloc.dart';

// ─── Alert Model ─────────────────────────────────────────────────────────────

enum AlertLevel { red, orange, yellow, blue }

class WeatherAlert {
  final String title;
  final String description;
  final String region;
  final AlertLevel level;
  final IconData icon;
  final String time;

  const WeatherAlert({
    required this.title,
    required this.description,
    required this.region,
    required this.level,
    required this.icon,
    required this.time,
  });
}

// ─── Alert Generator ──────────────────────────────────────────────────────────

List<WeatherAlert> generateAlerts(List<RegionWeather> regions) {
  final List<WeatherAlert> alerts = [];
  final now = DateTime.now();
  final timeStr =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  // Group regions by condition to combine into one alert
  final List<String> extremeHeat = [];
  final List<String> strongHeat = [];
  final List<String> mildHeat = [];
  final List<String> extremeWind = [];
  final List<String> strongWind = [];
  final List<String> mildWind = [];
  final List<String> storm = [];
  final List<String> heavyRain = [];
  final List<String> lightRain = [];
  final List<String> snow = [];
  final List<String> frost = [];
  final List<String> fog = [];

  for (final r in regions) {
    // Temperature thresholds
    if (r.temp >= 40) {
      extremeHeat.add(r.name);
    } else if (r.temp >= 35) {
      strongHeat.add(r.name);
    } else if (r.temp >= 32) {
      mildHeat.add(r.name);
    }
    if (r.temp <= -5) {
      frost.add(r.name);
    }

    // Wind thresholds (km/h)
    if (r.windSpeed >= 60) {
      extremeWind.add(r.name);
    } else if (r.windSpeed >= 38) {
      strongWind.add(r.name);
    } else if (r.windSpeed >= 25) {
      mildWind.add(r.name);
    }

    // Weather codes
    final c = r.weatherCode;
    if (c >= 95) {
      storm.add(r.name);
    } else if (c >= 61 && c <= 67) {
      heavyRain.add(r.name);
    } else if (c >= 51 && c <= 57) {
      lightRain.add(r.name);
    } else if (c >= 71 && c <= 77) {
      snow.add(r.name);
    } else if (c >= 45 && c <= 48) {
      fog.add(r.name);
    }
  }

  // Build alerts
  if (extremeHeat.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Favqulodda issiqlik xavfi",
        description:
            "Havo harorati 40°C dan oshdi. Ko'chaga chiqishni kamaytiring, ko'p suyuqlik iching va salqin joyda bo'ling.",
        region: extremeHeat.join(', '),
        level: AlertLevel.red,
        icon: LucideIcons.thermometerSun,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (strongHeat.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Kuchli issiqlik",
        description:
            "Harorat 35–40°C oralig'ida. Namlangib turing, og'ir jismoniy faoliyatni kechga qoldiring.",
        region: strongHeat.join(', '),
        level: AlertLevel.orange,
        icon: LucideIcons.thermometer,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (mildHeat.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Issiq ob-havo",
        description:
            "Harorat 32–35°C. Quyoshdan himoyalanib yuring, past intensivlikda harakat qiling.",
        region: mildHeat.join(', '),
        level: AlertLevel.yellow,
        icon: LucideIcons.sun,
        time: 'Bugun $timeStr',
      ),
    );
  }

  if (extremeWind.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Favqulodda bo'ron xavfi",
        description:
            "Shamol tezligi 60+ km/soat. Binolar ichida qoling, ochiq joylarda bo'lmang.",
        region: extremeWind.join(', '),
        level: AlertLevel.red,
        icon: LucideIcons.wind,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (strongWind.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Kuchli shamol",
        description:
            "Shamol tezligi 38–60 km/soat. Chang va to'zon mumkin, haydovchilar ehtiyot bo'lsin.",
        region: strongWind.join(', '),
        level: AlertLevel.orange,
        icon: LucideIcons.wind,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (mildWind.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Shamolли havo",
        description:
            "Shamol tezligi 25–38 km/soat. Yengil kiyimingizni bog'lab yuring.",
        region: mildWind.join(', '),
        level: AlertLevel.yellow,
        icon: LucideIcons.wind,
        time: 'Bugun $timeStr',
      ),
    );
  }

  if (storm.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Momaqaldiroq va chaqmoq xavfi",
        description:
            "Kuchli momaqaldiroq bilan yomg'ir kutilmoqda. Ochiq joylar va daraxtlardan uzoq bo'ling.",
        region: storm.join(', '),
        level: AlertLevel.red,
        icon: LucideIcons.cloudLightning,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (heavyRain.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Kuchli yomg'ir",
        description:
            "Intensiv yog'ingarchilik kutilmoqda. Sel va suv toshqi xavfi bor.",
        region: heavyRain.join(', '),
        level: AlertLevel.orange,
        icon: LucideIcons.cloudRain,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (lightRain.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Yomg'irli havo",
        description: "Yomg'ir yog'ishi kutilmoqda. Soyabon oling.",
        region: lightRain.join(', '),
        level: AlertLevel.yellow,
        icon: LucideIcons.cloudDrizzle,
        time: 'Bugun $timeStr',
      ),
    );
  }

  if (snow.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Qor yog'ishi",
        description:
            "Qor yog'ishi kutilmoqda. Yo'llar sirpanchiq bo'lishi mumkin, ehtiyot bo'ling.",
        region: snow.join(', '),
        level: AlertLevel.blue,
        icon: LucideIcons.snowflake,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (frost.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Sovuq va ayoz",
        description:
            "Harorat -5°C dan past. Issiq kiyinib chiqing, muzlashdan ehtiyot bo'ling.",
        region: frost.join(', '),
        level: AlertLevel.blue,
        icon: LucideIcons.thermometerSnowflake,
        time: 'Bugun $timeStr',
      ),
    );
  }
  if (fog.isNotEmpty) {
    alerts.add(
      WeatherAlert(
        title: "Qalin tuman",
        description:
            "Ko'rinish cheklangan. Haydovchilar yoqimli yorug'lik va past tezlik bilan harakatlaning.",
        region: fog.join(', '),
        level: AlertLevel.yellow,
        icon: LucideIcons.cloudFog,
        time: 'Bugun $timeStr',
      ),
    );
  }

  // Sort: red first, then orange, yellow, blue
  const order = {
    AlertLevel.red: 0,
    AlertLevel.orange: 1,
    AlertLevel.yellow: 2,
    AlertLevel.blue: 3,
  };
  alerts.sort((a, b) => (order[a.level] ?? 4).compareTo(order[b.level] ?? 4));

  return alerts;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const LoadMapEvent()),
      child: const _AlertsView(),
    );
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  Color _levelColor(AlertLevel l) {
    switch (l) {
      case AlertLevel.red:
        return const Color(0xFFEF4444);
      case AlertLevel.orange:
        return const Color(0xFFF97316);
      case AlertLevel.yellow:
        return const Color(0xFFEAB308);
      case AlertLevel.blue:
        return const Color(0xFF3B82F6);
    }
  }

  Color _levelBg(AlertLevel l, bool isDark) {
    switch (l) {
      case AlertLevel.red:
        return isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2);
      case AlertLevel.orange:
        return isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFF7ED);
      case AlertLevel.yellow:
        return isDark ? const Color(0xFF713F12) : const Color(0xFFFEFCE8);
      case AlertLevel.blue:
        return isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
    }
  }

  String _levelLabel(AlertLevel l) {
    switch (l) {
      case AlertLevel.red:
        return 'QIZIL';
      case AlertLevel.orange:
        return "TO'Q SARIQ";
      case AlertLevel.yellow:
        return 'SARIQ';
      case AlertLevel.blue:
        return "KO'K";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        const Text(
                          'Ogohlantirishlar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.bellRing,
                          color: Color(0xFFEF4444),
                          size: 22,
                        ),
                        const Spacer(),
                        if (state is MapLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF29B6F6),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(LucideIcons.refreshCw, size: 18),
                            onPressed: () => context.read<MapBloc>().add(
                              const LoadMapEvent(),
                            ),
                            tooltip: 'Yangilash',
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Subtitle ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Text(
                      "O'zbekiston viloyatlari bo'yicha haqiqiy vaqt ogohlantirishlari",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────────────────
                if (state is MapLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF29B6F6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Viloyatlar yuklanmoqda...',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is MapError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.alertTriangle,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text('Ma\'lumot yuklanmadi'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<MapBloc>().add(
                              const LoadMapEvent(),
                            ),
                            child: const Text('Qayta urinish'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is MapLoaded) ...[
                  Builder(
                    builder: (context) {
                      final alerts = generateAlerts(state.regions);
                      if (alerts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.shieldCheck,
                                    size: 42,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Xavf yo'q! 🎉",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Hozircha O'zbekiston bo'yicha\nxavfli ob-havo hodisalari aniqlanmadi.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            if (i == 0) {
                              // Summary bar
                              final red = alerts
                                  .where((a) => a.level == AlertLevel.red)
                                  .length;
                              final orange = alerts
                                  .where((a) => a.level == AlertLevel.orange)
                                  .length;
                              final yellow = alerts
                                  .where((a) => a.level == AlertLevel.yellow)
                                  .length;
                              final blue = alerts
                                  .where((a) => a.level == AlertLevel.blue)
                                  .length;
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black.withAlpha(8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _SummaryDot(
                                        count: red,
                                        color: const Color(0xFFEF4444),
                                        label: 'Qizil',
                                      ),
                                      _SummaryDot(
                                        count: orange,
                                        color: const Color(0xFFF97316),
                                        label: "To'q sariq",
                                      ),
                                      _SummaryDot(
                                        count: yellow,
                                        color: const Color(0xFFEAB308),
                                        label: 'Sariq',
                                      ),
                                      _SummaryDot(
                                        count: blue,
                                        color: const Color(0xFF3B82F6),
                                        label: "Ko'k",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final alert = alerts[i - 1];
                            final color = _levelColor(alert.level);
                            final bg = _levelBg(alert.level, isDark);

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: color.withAlpha(80),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            alert.icon,
                                            size: 22,
                                            color:
                                                alert.level == AlertLevel.yellow
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _levelLabel(alert.level),
                                                      style: TextStyle(
                                                        color:
                                                            alert.level ==
                                                                AlertLevel
                                                                    .yellow
                                                            ? Colors.black
                                                            : Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                alert.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    // Region
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.mapPin,
                                          size: 14,
                                          color: color,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            alert.region,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Time
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.clock,
                                          size: 13,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          alert.time,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Divider
                                    Divider(
                                      color: color.withAlpha(50),
                                      height: 1,
                                    ),
                                    const SizedBox(height: 10),
                                    // Description
                                    Text(
                                      alert.description,
                                      style: TextStyle(
                                        height: 1.55,
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: alerts.length + 1, // +1 for summary bar
                        ),
                      );
                    },
                  ),

                  // Bottom padding for nav bar
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SummaryDot extends StatelessWidget {
  final int count;
  final Color color;
  final String label;
  const _SummaryDot({
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(30),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
