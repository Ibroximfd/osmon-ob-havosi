import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../blocs/home_bloc/home_bloc.dart';
import '../../blocs/home_bloc/home_state_event.dart';

class AirQualityPage extends StatelessWidget {
  const AirQualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeLoaded) {
            final aqi = state.weather.aqi;

            // Determine status and color based on US AQI logic
            String status = 'Yaxshi';
            Color color = Colors.green;
            String message =
                "Havo sifati qoniqarli, havo ifloslanishi xavf tug'dirmaydi.";

            if (aqi > 50 && aqi <= 100) {
              status = "O'rtacha";
              color = Colors.yellow;
              message =
                  "Ba'zi ifloslantiruvchi moddalar nozik insonlar uchun xavf tug'dirishi mumkin.";
            } else if (aqi > 100 && aqi <= 150) {
              status = 'Nozik guruhlar uchun zararli';
              color = Colors.orange;
              message =
                  "Nozik guruhlar a'zolari sog'liqqa ta'sir qilishi mumkin. Umumiy jamoatchilik ta'sir qilmasligi ehtimoli kamroq.";
            } else if (aqi > 150 && aqi <= 200) {
              status = 'Zararli';
              color = Colors.red;
              message =
                  "Har kim sog'liqqa ta'sir qilishi mumkin; nozik guruhlar a'zolari jiddiy sog'liqqa ta'sir qilishi mumkin.";
            } else if (aqi > 200 && aqi <= 300) {
              status = 'Juda zararli';
              color = Colors.purple;
              message =
                  "Sog'liq uchun ogohlantirishlar: har kim jiddiy sog'liqqa ta'sir qilishi mumkin.";
            } else if (aqi > 300) {
              status = 'Xavfli';
              color = Colors.brown;
              message =
                  "Sog'liq haqida favqulodda ogohlantirishlar: butun aholi ta'sir qilishi ehtimoli ko'proq.";
            }

            final pollutants = [
              {'name': 'PM2.5', 'value': 12, 'unit': 'µg/m³'},
              {'name': 'PM10', 'value': 24, 'unit': 'µg/m³'},
              {'name': 'O3', 'value': 45, 'unit': 'µg/m³'},
              {'name': 'NO2', 'value': 15, 'unit': 'µg/m³'},
              {'name': 'SO2', 'value': 2, 'unit': 'µg/m³'},
              {'name': 'CO', 'value': 0.4, 'unit': 'µg/m³'},
            ];

            return SafeArea(
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
                          'Havo sifati',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Gauge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Gauge Circle
                          SizedBox(
                            height: 180,
                            width: 180,
                            child: Stack(
                              children: [
                                Transform.rotate(
                                  angle: -pi,
                                  child: CustomPaint(
                                    size: const Size(180, 180),
                                    painter: _GaugePainter(
                                      color: color,
                                      backgroundColor: isDark
                                          ? Colors.white12
                                          : Colors.black12,
                                      percentage: (aqi / 500).clamp(0.0, 1.0),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$aqi',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'AQI',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Health Tips
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                LucideIcons.heartPulse,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Sog'liq uchun maslahatlar",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTipItem(
                            color,
                            "Ochiq havoda sayr qilish uchun ajoyib vaqt.",
                          ),
                          const SizedBox(height: 12),
                          _buildTipItem(
                            color,
                            "Uyni shamollatish uchun derazalarni ochishingiz mumkin.",
                          ),
                          const SizedBox(height: 12),
                          _buildTipItem(
                            color,
                            "Sport bilan shug'ullanish tavsiya etiladi.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pollutants
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Ifloslantiruvchi moddalar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: pollutants.length,
                      itemBuilder: (context, index) {
                        final item = pollutants[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Icon(
                                    LucideIcons.activity,
                                    size: 16,
                                    color: Colors.green,
                                  ), // could be dynamic based on value
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${item['value']}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['unit'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTipItem(Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final double percentage;

  _GaugePainter({
    required this.color,
    required this.backgroundColor,
    required this.percentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // Start angle
      2 * pi, // Sweep angle
      false,
      bgPaint,
    );

    // Draw foreground arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2,
      2 * pi * percentage,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simple approach
  }
}
