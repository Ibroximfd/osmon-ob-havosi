import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/region_weather.dart';
import '../../blocs/map_bloc/map_bloc.dart';

// Updated accurate map coordinates for all 14 provinces within screen bounds
// mapX: 0.05–0.93 (left-right), mapY: 0.13–0.78 (top-bottom, avoids header+nav)
const List<RegionCity> _uzRegions = [
  RegionCity(name: 'Nukus', lat: 42.4619, lon: 59.6166, mapX: 0.05, mapY: 0.13),
  RegionCity(
    name: 'Urganch',
    lat: 41.5533,
    lon: 60.6347,
    mapX: 0.13,
    mapY: 0.24,
  ),
  RegionCity(
    name: 'Buxoro',
    lat: 39.7747,
    lon: 64.4286,
    mapX: 0.30,
    mapY: 0.60,
  ),
  RegionCity(
    name: 'Navoiy',
    lat: 40.0844,
    lon: 65.3792,
    mapX: 0.38,
    mapY: 0.52,
  ),
  RegionCity(
    name: 'Samarqand',
    lat: 39.627,
    lon: 66.9749,
    mapX: 0.46,
    mapY: 0.64,
  ),
  RegionCity(
    name: 'Qarshi',
    lat: 38.8606,
    lon: 65.7891,
    mapX: 0.38,
    mapY: 0.74,
  ),
  RegionCity(
    name: 'Termiz',
    lat: 37.2242,
    lon: 67.2783,
    mapX: 0.47,
    mapY: 0.84,
  ),
  RegionCity(
    name: 'Jizzax',
    lat: 40.1158,
    lon: 67.8422,
    mapX: 0.54,
    mapY: 0.52,
  ),
  RegionCity(
    name: 'Sirdaryo',
    lat: 40.8347,
    lon: 68.6642,
    mapX: 0.60,
    mapY: 0.42,
  ),
  RegionCity(
    name: 'Toshkent',
    lat: 41.2995,
    lon: 69.2401,
    mapX: 0.65,
    mapY: 0.28,
  ),
  RegionCity(
    name: "Farg'ona",
    lat: 40.3842,
    lon: 71.7843,
    mapX: 0.88,
    mapY: 0.60,
  ),
  RegionCity(
    name: 'Namangan',
    lat: 41.0011,
    lon: 71.6676,
    mapX: 0.85,
    mapY: 0.30,
  ),
  RegionCity(
    name: 'Andijon',
    lat: 40.7821,
    lon: 72.3442,
    mapX: 0.93,
    mapY: 0.48,
  ),
  RegionCity(
    name: "Qo'qon",
    lat: 40.5283,
    lon: 70.9425,
    mapX: 0.80,
    mapY: 0.54,
  ),
];

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const LoadMapEvent()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();
  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  String _activeLayer = 'temp';
  RegionWeather? _selected;
  Offset _panOffset = Offset.zero;

  final List<Map<String, dynamic>> _layers = [
    {'id': 'temp', 'icon': LucideIcons.thermometer, 'label': 'Harorat'},
    {'id': 'wind', 'icon': LucideIcons.wind, 'label': 'Shamol'},
    {'id': 'hum', 'icon': LucideIcons.droplets, 'label': 'Namlik'},
  ];

  Color _tempColor(int temp) {
    if (temp <= 0) return const Color(0xFF60A5FA);
    if (temp <= 10) return const Color(0xFF34D399);
    if (temp <= 20) return const Color(0xFF86EFAC);
    if (temp <= 30) return const Color(0xFFFBBF24);
    if (temp <= 36) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  String _layerValue(RegionWeather r) {
    switch (_activeLayer) {
      case 'wind':
        return '${r.windSpeed.round()} km/s';
      case 'hum':
        return '${r.humidity}%';
      default:
        return '${r.temp}°';
    }
  }

  Color _layerColor(RegionWeather r) {
    switch (_activeLayer) {
      case 'wind':
        if (r.windSpeed < 10) return Colors.green;
        if (r.windSpeed < 30) return Colors.orange;
        return Colors.red;
      case 'hum':
        if (r.humidity < 30) return Colors.orange;
        if (r.humidity > 80) return Colors.blue;
        return Colors.teal;
      default:
        return _tempColor(r.temp);
    }
  }

  IconData _weatherIcon(int code, bool isDay) {
    if (code == 0) return isDay ? LucideIcons.sun : LucideIcons.moon;
    if (code <= 3) return LucideIcons.cloud;
    if (code <= 48) return LucideIcons.cloudFog;
    if (code <= 67) return LucideIcons.cloudRain;
    if (code <= 77) return LucideIcons.cloudSnow;
    return LucideIcons.cloudLightning;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final W = constraints.maxWidth;
              final H = constraints.maxHeight;

              return Stack(
                children: [
                  // ─── Pannable map area ─────────────────────────────
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final newX = _panOffset.dx + details.delta.dx;
                        final newY = _panOffset.dy + details.delta.dy;
                        // Clamp so map doesn't slide too far off screen
                        _panOffset = Offset(
                          newX.clamp(-W * 0.4, W * 0.4),
                          newY.clamp(-H * 0.3, H * 0.3),
                        );
                      });
                    },
                    child: Container(
                      width: W,
                      height: H,
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFEFF6FF),
                      child: ClipRect(
                        child: Stack(
                          children: [
                            // Map outline
                            Transform.translate(
                              offset: _panOffset,
                              child: Opacity(
                                opacity: isDark ? 0.08 : 0.15,
                                child: CustomPaint(
                                  size: Size(W, H),
                                  painter: _UzbekistanOutlinePainter(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ),

                            // Glow
                            Transform.translate(
                              offset: _panOffset,
                              child: Center(
                                child: Container(
                                  width: W * 0.9,
                                  height: H * 0.7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFF29B6F6,
                                        ).withAlpha(isDark ? 35 : 55),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Markers — lookup real data by city name
                            if (state is MapLoaded)
                              ..._uzRegions.map((region) {
                                final data = state.regions
                                    .cast<RegionWeather?>()
                                    .firstWhere(
                                      (r) => r?.name == region.name,
                                      orElse: () => null,
                                    );
                                if (data == null) {
                                  return const SizedBox.shrink();
                                }

                                final isSelected = _selected?.name == data.name;
                                final color = _layerColor(data);
                                final cx = W * region.mapX + _panOffset.dx;
                                final cy = H * region.mapY + _panOffset.dy;

                                return Positioned(
                                  left: cx,
                                  top: cy,
                                  child: FractionalTranslation(
                                    translation: const Offset(-0.5, -0.5),
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selected = isSelected
                                            ? null
                                            : data,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isSelected ? 12 : 9,
                                              vertical: isSelected ? 6 : 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? color
                                                  : (isDark
                                                        ? Colors.black
                                                              .withAlpha(190)
                                                        : Colors.white
                                                              .withAlpha(225)),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: color,
                                                width: isSelected ? 2 : 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withAlpha(
                                                    isSelected ? 130 : 60,
                                                  ),
                                                  blurRadius: isSelected
                                                      ? 14
                                                      : 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              _layerValue(data),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isSelected ? 14 : 12,
                                                color: isSelected
                                                    ? Colors.white
                                                    : color,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? color
                                                  : Colors.black.withAlpha(165),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              region.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── Loading ─────────────────────────────────────────
                  if (state is MapLoading)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF29B6F6)),
                          SizedBox(height: 16),
                          Text('Viloyatlar yuklanmoqda...'),
                        ],
                      ),
                    ),

                  // ─── Error ───────────────────────────────────────────
                  if (state is MapError)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.alertTriangle,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text('Xarita yuklanmadi'),
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

                  // ─── Header ──────────────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        left: 24,
                        right: 24,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withAlpha(200),
                            Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "O'zbekiston ob-havo xaritasi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(LucideIcons.refreshCw, size: 18),
                              onPressed: () {
                                setState(() => _panOffset = Offset.zero);
                                context.read<MapBloc>().add(
                                  const LoadMapEvent(),
                                );
                              },
                              tooltip: "Yangilash",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Layer Toggle ─────────────────────────────────────
                  Positioned(
                    bottom: 130,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withAlpha(200)
                            : Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _layers.map((layer) {
                          final isActive = _activeLayer == layer['id'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _activeLayer = layer['id']),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF1565C0)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  layer['icon'],
                                  size: 20,
                                  color: isActive
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // ─── Pan hint ─────────────────────────────────────────
                  Positioned(
                    bottom: 130,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withAlpha(190)
                            : Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.move,
                            size: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Suring',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Selected region detail ───────────────────────────
                  if (_selected != null)
                    Positioned(
                      bottom: 130,
                      left: 80,
                      right: 24,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = null),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withAlpha(235)
                                : Colors.white.withAlpha(245),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _layerColor(_selected!).withAlpha(150),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(60),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selected!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    _weatherIcon(
                                      _selected!.weatherCode,
                                      _selected!.isDay,
                                    ),
                                    color: const Color(0xFF29B6F6),
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _DetailItem(
                                    icon: LucideIcons.thermometer,
                                    label: 'Harorat',
                                    value: '${_selected!.temp}°C',
                                    color: _tempColor(_selected!.temp),
                                  ),
                                  _DetailItem(
                                    icon: LucideIcons.wind,
                                    label: 'Shamol',
                                    value:
                                        '${_selected!.windSpeed.round()} km/s',
                                    color: Colors.teal,
                                  ),
                                  _DetailItem(
                                    icon: LucideIcons.droplets,
                                    label: 'Namlik',
                                    value: '${_selected!.humidity}%',
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _UzbekistanOutlinePainter extends CustomPainter {
  final Color color;
  const _UzbekistanOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final W = size.width;
    final H = size.height;
    final path = Path();
    path.moveTo(W * 0.05, H * 0.28);
    path.lineTo(W * 0.12, H * 0.15);
    path.lineTo(W * 0.25, H * 0.12);
    path.lineTo(W * 0.38, H * 0.18);
    path.lineTo(W * 0.55, H * 0.16);
    path.lineTo(W * 0.68, H * 0.20);
    path.lineTo(W * 0.78, H * 0.18);
    path.lineTo(W * 0.88, H * 0.26);
    path.lineTo(W * 0.95, H * 0.38);
    path.lineTo(W * 0.92, H * 0.52);
    path.lineTo(W * 0.85, H * 0.58);
    path.lineTo(W * 0.75, H * 0.60);
    path.lineTo(W * 0.65, H * 0.70);
    path.lineTo(W * 0.60, H * 0.85);
    path.lineTo(W * 0.50, H * 0.95);
    path.lineTo(W * 0.40, H * 0.90);
    path.lineTo(W * 0.28, H * 0.85);
    path.lineTo(W * 0.18, H * 0.75);
    path.lineTo(W * 0.10, H * 0.62);
    path.lineTo(W * 0.05, H * 0.48);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
