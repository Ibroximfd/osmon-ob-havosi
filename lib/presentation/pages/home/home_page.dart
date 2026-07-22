import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../ads/ad_config.dart';
import '../../../ads/widgets/native_ad_card.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/update_checker.dart';
import '../../../domain/entities/weather.dart';
import '../../blocs/home_bloc/home_bloc.dart';
import '../../blocs/home_bloc/home_state_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (context.read<HomeBloc>().state is HomeInitial) {
      _loadInitialWeather();
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) UpdateChecker.check(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // App sozlamalaridan qaytganda permission tekshiriladi
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final bloc = context.read<HomeBloc>();
      if (bloc.state is HomeInitial || bloc.state is HomeError) {
        _loadInitialWeather();
      }
    }
  }

  // Location ruxsat/servis bo'lmasa ham UI hech qachon bloklanmaydi:
  // GPS ishlamasa oxirgi ma'lum joylashuv (yoki Toshkent) bilan ob-havo
  // darhol ko'rsatiladi, va faqat bloklamaydigan SnackBar orqali eslatma beriladi.
  Future<void> _loadInitialWeather() async {
    if (!mounted) return;
    final bloc = context.read<HomeBloc>();

    final city = await LocationService.resolveCurrentCity();
    if (!mounted) return;

    if (city != null) {
      bloc.add(LoadWeatherEvent(city));
      return;
    }

    final fallbackCity = await LocationService.getFallbackCity();
    if (!mounted) return;
    bloc.add(LoadWeatherEvent(fallbackCity));
    _showLocationHint();
  }

  void _showLocationHint() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: const Text("Aniqroq ob-havo uchun joylashuvni yoqing"),
          action: SnackBarAction(
            label: 'Yoqish',
            onPressed: () => LocationService.openLocationSettings(),
          ),
        ),
      );
    });
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
                    onPressed: _loadInitialWeather,
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
                child: RefreshIndicator(
                  color: const Color(0xFF29B6F6),
                  onRefresh: () => _loadInitialWeather(),
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.sparkles),
                                  onPressed: () =>
                                      context.push(AppRoutes.chat),
                                  style: IconButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.black26
                                        : Colors.white24,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(LucideIcons.search),
                                  onPressed: () =>
                                      context.push(AppRoutes.search),
                                  style: IconButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.black26
                                        : Colors.white24,
                                  ),
                                ),
                              ],
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
                              "His qilish: ${weather.feelsLike}° • Max: ${weather.daily[0].max}° • Min: ${weather.daily[0].min}°",
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
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E3A8A).withAlpha(60),
                                      const Color(0xFF1565C0).withAlpha(20),
                                    ]
                                  : [
                                      const Color(0xFFE0F2FE),
                                      const Color(0xFFF0F9FF),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFF29B6F6).withAlpha(60),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29B6F6).withAlpha(30),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF29B6F6)
                                          .withAlpha(40),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: state.isAdviceLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF29B6F6),
                                            ),
                                          )
                                        : const Icon(
                                            LucideIcons.sparkles,
                                            color: Color(0xFF29B6F6),
                                            size: 16,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'AI Yordamchi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF29B6F6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (state.isAdviceLoading)
                                    Text(
                                      'fikrlamoqda...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              state.isAdviceLoading
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _shimmerLine(isDark, 1.0),
                                        const SizedBox(height: 8),
                                        _shimmerLine(isDark, 0.95),
                                        const SizedBox(height: 8),
                                        _shimmerLine(isDark, 0.85),
                                        const SizedBox(height: 8),
                                        _shimmerLine(isDark, 0.7),
                                        const SizedBox(height: 8),
                                        _shimmerLine(isDark, 0.5),
                                      ],
                                    )
                                  : Text(
                                      state.advice,
                                      softWrap: true,
                                      style: TextStyle(
                                        height: 1.7,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
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

                      // Weather Score
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 16,
                        ),
                        child: _buildWeatherScore(weather, isDark),
                      ),

                      // Clothing Advice
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 16,
                        ),
                        child: _buildClothingAdvice(weather, isDark),
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
                              child: Builder(
                                builder: (context) {
                                  final hourlyList = weather.hourly
                                      .where(
                                        (e) =>
                                            weather.hourly.indexOf(e) % 2 == 0,
                                      )
                                      .toList();
                                  const adEvery = AdConfig.nativeAdEveryNItems;
                                  const groupSize = adEvery + 1;
                                  final adCount = hourlyList.isEmpty
                                      ? 0
                                      : (hourlyList.length - 1) ~/ adEvery;
                                  final itemCount =
                                      hourlyList.length + adCount;

                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: itemCount,
                                    separatorBuilder: (context, _) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final isAdSlot =
                                          (index + 1) % groupSize == 0;
                                      if (isAdSlot) {
                                        return SizedBox(
                                          width: 140,
                                          child: NativeAdCard(
                                            slotKey:
                                                'home_hourly_${index ~/ groupSize}',
                                            height: 120,
                                          ),
                                        );
                                      }

                                      final realIndex =
                                          index - (index ~/ groupSize);
                                      final item = hourlyList[realIndex];
                                      final isFirst = realIndex == 0;

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
                                          borderRadius: BorderRadius.circular(
                                            35,
                                          ),
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
                                              _getIcon(
                                                item.code,
                                                weather.isDay,
                                              ),
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
                                      state.isAdviceLoading
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _shimmerLine(isDark, 1.0),
                                                const SizedBox(height: 6),
                                                _shimmerLine(isDark, 0.7),
                                              ],
                                            )
                                          : Text(
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
            ),
          );
        }

        return const Scaffold();
      },
    );
  }

  Widget _shimmerLine(bool isDark, double widthFactor) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.black.withAlpha(15),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildClothingAdvice(Weather weather, bool isDark) {
    final t = weather.temp;
    final c = weather.condition.toLowerCase();
    final isRain =
        c.contains('yomg') || c.contains('kuchli') || c.contains('jala');
    final isSnow = c.contains('qor');
    final isStorm = c.contains('momaqaldiroq');

    final items = <_ClothingItem>[];

    if (isStorm) {
      items.addAll([
        _ClothingItem('⛈️', 'Uyda qoling'),
        _ClothingItem('📱', 'Favqulodda'),
      ]);
    } else {
      if (t > 35) {
        items.addAll([
          _ClothingItem('👕', 'Yengil kiyim'),
          _ClothingItem('🧢', 'Shapka'),
          _ClothingItem('🕶️', 'Ko\'zoynak'),
          _ClothingItem('💧', 'Ko\'p suv iching'),
        ]);
      } else if (t > 25) {
        items.addAll([
          _ClothingItem('👕', 'Yengil kiyim'),
          _ClothingItem('🕶️', 'Ko\'zoynak'),
        ]);
      } else if (t > 15) {
        items.addAll([
          _ClothingItem('👔', 'Oddiy kiyim'),
          _ClothingItem('🧴', 'Quyosh kremı'),
        ]);
      } else if (t > 5) {
        items.addAll([
          _ClothingItem('🧥', 'Kurtka'),
          _ClothingItem('🧣', 'Sharf'),
        ]);
      } else {
        items.addAll([
          _ClothingItem('🧥', 'Qalin kurtka'),
          _ClothingItem('🧣', 'Sharf'),
          _ClothingItem('🧤', 'Qo\'lqop'),
        ]);
      }
      if (isRain) items.add(_ClothingItem('☂️', 'Soyabon oling'));
      if (isSnow) items.add(_ClothingItem('🥾', 'Issiq etik'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('👗', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bugun nima kiyish kerak?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(12)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _calcScore(Weather weather) {
    int score = 10;

    final t = weather.temp;
    if (t < 0 || t > 40) {
      score -= 3;
    } else if (t < 8 || t > 36) {
      score -= 2;
    } else if (t < 15 || t > 30) {
      score -= 1;
    }

    if (weather.humidity > 88 || weather.humidity < 18) {
      score -= 2;
    } else if (weather.humidity > 72) {
      score -= 1;
    }

    if (weather.windSpeed > 40) {
      score -= 2;
    } else if (weather.windSpeed > 25) {
      score -= 1;
    }

    final c = weather.condition.toLowerCase();
    if (c.contains('momaqaldiroq')) {
      score -= 3;
    } else if (c.contains('kuchli') || c.contains('qor')) {
      score -= 2;
    } else if (c.contains('yomg') || c.contains('tuman')) {
      score -= 1;
    }

    return score.clamp(1, 10);
  }

  Widget _buildWeatherScore(Weather weather, bool isDark) {
    final score = _calcScore(weather);

    final Color color;
    final String label;
    final String tip;
    final IconData icon;

    if (score >= 9) {
      color = const Color(0xFF22C55E);
      label = 'Mukammal kun!';
      tip = 'Tashqarida sayr qilish, sport va dam olish uchun ideal';
      icon = Icons.sentiment_very_satisfied_rounded;
    } else if (score >= 7) {
      color = const Color(0xFF84CC16);
      label = 'Yaxshi kun';
      tip = 'Tashqi faoliyat uchun qulay sharoit';
      icon = Icons.sentiment_satisfied_rounded;
    } else if (score >= 5) {
      color = const Color(0xFFF59E0B);
      label = "O'rtacha kun";
      tip = 'Ehtiyot bo\'ling, ob-havo o\'zgaruvchan';
      icon = Icons.sentiment_neutral_rounded;
    } else if (score >= 3) {
      color = const Color(0xFFEF4444);
      label = 'Noqulay havo';
      tip = 'Zarur bo\'lmasa tashqariga chiqmaslik tavsiya etiladi';
      icon = Icons.sentiment_dissatisfied_rounded;
    } else {
      color = const Color(0xFF9333EA);
      label = 'Og\'ir ob-havo';
      tip = 'Uyda qolish va ehtiyot choralarini ko\'rish kerak';
      icon = Icons.sentiment_very_dissatisfied_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(40),
            color.withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30),
              border: Border.all(color: color, width: 2.5),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score/10',
            style: TextStyle(
              fontSize: 11,
              color: color.withAlpha(180),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

class _ClothingItem {
  final String emoji;
  final String label;
  const _ClothingItem(this.emoji, this.label);
}
