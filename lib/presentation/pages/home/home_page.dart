import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/city.dart';
import '../../blocs/home_bloc/home_bloc.dart';
import '../../blocs/home_bloc/home_state_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch default Toshkent weather on start if not already loaded
    if (context.read<HomeBloc>().state is HomeInitial) {
      context.read<HomeBloc>().add(LoadWeatherEvent(City.cities[0]));
    }
  }

  IconData _getIcon(int code, bool isDay) {
    if (code == 0) return isDay ? LucideIcons.sun : LucideIcons.moon;
    if (code == 1 || code == 2 || code == 3) return LucideIcons.cloud;
    if (code >= 45 && code <= 48) return LucideIcons.cloudFog;
    if (code >= 51 && code <= 67) return LucideIcons.cloudRain;
    if (code >= 71 && code <= 77) return LucideIcons.cloudSnow;
    if (code >= 80 && code <= 82) return LucideIcons.cloudRain;
    if (code >= 95 && code <= 99) return LucideIcons.cloudLightning;
    return LucideIcons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1565C0)),
            ),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Xatolik yuz berdi",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(state.message),
                  TextButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(
                        LoadWeatherEvent(City.cities[0]),
                      );
                    },
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          final weather = state.weather;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          List<Color> bgGradient;
          if (weather.isDay) {
            bgGradient = weather.condition.contains('Ochiq')
                ? [
                    const Color(0x33F6AD55),
                    Theme.of(context).scaffoldBackgroundColor,
                  ] // Light orange to bg
                : [
                    const Color(0x3363B3ED),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]; // Light blue to bg
          } else {
            bgGradient = [
              const Color(0x66312E81),
              Theme.of(context).scaffoldBackgroundColor,
            ]; // Indigo to bg
          }

          if (isDark) {
            if (weather.isDay) {
              bgGradient = weather.condition.contains('Ochiq')
                  ? [
                      const Color(0x4D7B341E),
                      Theme.of(context).scaffoldBackgroundColor,
                    ]
                  : [
                      const Color(0x4D1E3A8A),
                      Theme.of(context).scaffoldBackgroundColor,
                    ];
            } else {
              bgGradient = [
                const Color(0x801E1B4B),
                Theme.of(context).scaffoldBackgroundColor,
              ];
            }
          }

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: bgGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1565C0),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'O',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'OSMON',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.search),
                              onPressed: () => context.push(AppRoutes.search),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.black26
                                    : Colors.white24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main Weather
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.search),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.mapPin,
                                    size: 18,
                                    color: Color(0xFF29B6F6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${weather.city}, O'zbekiston",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Text(
                                  '${weather.temp}°',
                                  style: const TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.w300,
                                    height: 1.0,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 10,
                                  child: Icon(
                                    weather.isDay
                                        ? LucideIcons.sun
                                        : LucideIcons.moon,
                                    size: 48,
                                    color: const Color(0xFF29B6F6),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              weather.condition,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Hissiyot: ${weather.feelsLike}° • Eng yuqori: ${weather.daily[0].max}° • Eng past: ${weather.daily[0].min}°",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // AI Advice
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 24,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white24,
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF29B6F6),
                                width: 4,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0, right: 12.0),
                                child: Icon(
                                  LucideIcons.sparkles,
                                  color: Color(0xFF29B6F6),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  state.advice,
                                  softWrap: true,
                                  style: TextStyle(
                                    height: 1.6,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quick Stats
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 24,
                        ),
                        child: Row(
                          children: [
                            _buildQuickStat(
                              isDark,
                              LucideIcons.wind,
                              'Shamol',
                              '${weather.windSpeed} km/s',
                            ),
                            const SizedBox(width: 12),
                            _buildQuickStat(
                              isDark,
                              LucideIcons.droplets,
                              'Namlik',
                              '${weather.humidity}%',
                            ),
                            const SizedBox(width: 12),
                            _buildQuickStat(
                              isDark,
                              LucideIcons.thermometer,
                              'Bosim',
                              '${weather.pressure} hPa',
                            ),
                          ],
                        ),
                      ),

                      // Hourly Forecast
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                '24 soatlik prognoz',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: weather.hourly
                                    .where(
                                      (e) => weather.hourly.indexOf(e) % 2 == 0,
                                    )
                                    .length,
                                separatorBuilder: (context, _) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final hourlyList = weather.hourly
                                      .where(
                                        (e) =>
                                            weather.hourly.indexOf(e) % 2 == 0,
                                      )
                                      .toList();
                                  final item = hourlyList[index];
                                  final isFirst = index == 0;

                                  return Container(
                                    width: 70,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFirst
                                          ? const Color(0xFF1565C0)
                                          : (isDark
                                                ? Colors.black26
                                                : Colors.white24),
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.time,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isFirst
                                                ? Colors.white
                                                : (isDark
                                                      ? Colors.white70
                                                      : Colors.black87),
                                          ),
                                        ),
                                        Icon(
                                          _getIcon(item.code, weather.isDay),
                                          color: isFirst
                                              ? Colors.white
                                              : const Color(0xFF29B6F6),
                                        ),
                                        Text(
                                          '${item.temp}°',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isFirst
                                                ? Colors.white
                                                : (isDark
                                                      ? Colors.white
                                                      : Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Weekly Forecast
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white24,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '7 kunlik prognoz',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        context.push(AppRoutes.forecast),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Batafsil',
                                          style: TextStyle(
                                            color: Color(0xFF29B6F6),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          LucideIcons.chevronRight,
                                          size: 14,
                                          color: Color(0xFF29B6F6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ...weather.daily.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          item.day,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        _getIcon(item.code, true),
                                        color: const Color(0xFF29B6F6),
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Row(
                                          children: [
                                            Text(
                                              '${item.min}°',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.white54
                                                    : Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Colors.white12
                                                      : Colors.black12,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: FractionallySizedBox(
                                                  alignment: Alignment.center,
                                                  widthFactor: 0.6,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFF29B6F6),
                                                              Color(0xFFFFB300),
                                                            ],
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${item.max}°',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // AQI & Agriculture Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push(AppRoutes.airQuality),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black26
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            LucideIcons.wind,
                                            size: 20,
                                            color: Color(0xFF29B6F6),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'HAVO SIFATI',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF29B6F6),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '${weather.aqi}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        weather.aqi <= 50
                                            ? 'Yaxshi'
                                            : (weather.aqi <= 100
                                                  ? "O'rtacha"
                                                  : 'Yomon'),
                                        style: TextStyle(
                                          color: weather.aqi <= 50
                                              ? Colors.green
                                              : (weather.aqi <= 100
                                                    ? Colors.orange
                                                    : Colors.red),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    context.push(AppRoutes.agriculture),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black26
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            LucideIcons.sun,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'DEHQONLAR',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        state.agricultureAdvice,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const Scaffold();
      },
    );
  }

  Widget _buildQuickStat(
    bool isDark,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.white24,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF29B6F6)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
