import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../blocs/home_bloc/home_bloc.dart';
import '../../blocs/home_bloc/home_state_event.dart';
import '../../../domain/entities/weather.dart';

class AgriculturePage extends StatelessWidget {
  const AgriculturePage({super.key});

  String _agriStatus(Weather w) {
    if (w.temp < 0) return "Ekin ishlari uchun qulay emas";
    if (w.temp >= 5 && w.temp <= 30 && w.humidity >= 30 && w.humidity <= 80) {
      return "Ekin ekish uchun qulay";
    }
    if (w.temp > 35) return "Juda issiq — erta tongda ishlang";
    if (w.humidity > 85) return "Namlik yuqori — kasallik xavfi bor";
    return "Ob-havo o'rtacha qulay";
  }

  Color _statusColor(Weather w) {
    if (w.temp < 0 || w.humidity > 85) return Colors.red;
    if (w.temp > 35) return Colors.orange;
    return Colors.green;
  }

  IconData _statusIcon(Weather w) {
    if (w.temp < 0) return LucideIcons.snowflake;
    if (w.temp > 35) return LucideIcons.sun;
    if (w.humidity > 85) return LucideIcons.cloudRain;
    return LucideIcons.sprout;
  }

  List<Map<String, String>> _buildTasks(Weather w) {
    final tasks = <Map<String, String>>[];

    // Sug'orish tavsiyasi
    if (w.humidity < 40) {
      tasks.add({
        'title': "Sug'orish zarur",
        'time': 'Bugun, 17:00–19:00',
        'status': 'warning',
        'desc':
            "Namlik ${w.humidity}% — past. Ekinlarni kechki paytda sug'orish tavsiya qilinadi.",
      });
    } else if (w.humidity > 80) {
      tasks.add({
        'title': "Sug'orishni to'xtatib turing",
        'time': 'Hozir',
        'status': 'warning',
        'desc':
            "Namlik ${w.humidity}% — juda yuqori. Ortiqcha suv kasallikka olib kelishi mumkin.",
      });
    } else {
      tasks.add({
        'title': "Sug'orish rejimi normal",
        'time': 'Bugun, 18:00',
        'status': 'optimal',
        'desc':
            "Namlik ${w.humidity}% — qulay. Oddiy sug'orish rejimida davom eting.",
      });
    }

    // Haroratga qarab
    if (w.temp > 30) {
      tasks.add({
        'title': "Issiqlikdan himoya",
        'time': '11:00–16:00',
        'status': 'warning',
        'desc':
            "Harorat ${w.temp}°C. Ushbu soatlarda dala ishlarini kamaytiring, ekinlarni soyalang.",
      });
    } else if (w.temp >= 15 && w.temp <= 25) {
      tasks.add({
        'title': "Ko'chat o'tkazish uchun qulay",
        'time': 'Bugun, 08:00–11:00',
        'status': 'optimal',
        'desc':
            "Harorat ${w.temp}°C — ko'chat o'tkazish va ekin ekish uchun ideal.",
      });
    }

    // Shamolga qarab
    if (w.windSpeed > 30) {
      tasks.add({
        'title': "Purkash ishlarini to'xtatib turing",
        'time': 'Hozir',
        'status': 'warning',
        'desc':
            "Shamol tezligi ${w.windSpeed} km/s. Pestitsid va dori purkashni tugatmang.",
      });
    } else {
      tasks.add({
        'title': "Dori va o'g'it purkash uchun qulay",
        'time': 'Ertaga, 07:00',
        'status': 'optimal',
        'desc':
            "Shamol tezligi ${w.windSpeed} km/s — past. Purkash uchun qulay sharoit.",
      });
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final weather = state.weather;
        final agriAdvice = state.agricultureAdvice;
        final statusColor = _statusColor(weather);
        final tasks = _buildTasks(weather);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ).copyWith(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Dehqonlar uchun',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Main Status — dynamic
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withAlpha(50),
                          statusColor.withAlpha(25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: statusColor.withAlpha(80)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withAlpha(100),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _statusIcon(weather),
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _agriStatus(weather),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          agriAdvice,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            height: 1.6,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Real weather metrics
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Hozirgi ob-havo ko\'rsatkichlari',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: LucideIcons.droplets,
                          iconColor: Colors.blue,
                          label: "Havo namligi",
                          value: '${weather.humidity}%',
                          subtitle: weather.humidity < 40
                              ? "Past — sug'orish kerak"
                              : weather.humidity > 80
                              ? 'Yuqori — ehtiyot bo\'ling'
                              : "Qulay",
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricCard(
                          icon: LucideIcons.thermometerSun,
                          iconColor: Colors.orange,
                          label: "Harorat",
                          value: '${weather.temp}°C',
                          subtitle: weather.temp > 35
                              ? 'Juda issiq'
                              : weather.temp < 5
                              ? 'Sovuq'
                              : 'Qulay',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: LucideIcons.wind,
                          iconColor: Colors.teal,
                          label: "Shamol",
                          value: '${weather.windSpeed} km/s',
                          subtitle: weather.windSpeed > 30
                              ? 'Kuchli — purkash to\'xtatilsin'
                              : 'Qulay',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricCard(
                          icon: LucideIcons.cloud,
                          iconColor: Colors.grey,
                          label: "Holat",
                          value: '',
                          subtitle: weather.condition,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dynamic Tasks
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Bugungi tavsiyalar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...tasks.map((task) {
                    final isWarning = task['status'] == 'warning';
                    final color = isWarning ? Colors.orange : Colors.green;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(color: color, offset: const Offset(-4, 0)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  task['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.clock,
                                      size: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task['time']!,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            task['desc']!,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              height: 1.5,
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
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;
  final bool isDark;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
