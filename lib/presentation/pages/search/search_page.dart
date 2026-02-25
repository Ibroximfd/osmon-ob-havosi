import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../domain/entities/city.dart';
import '../../blocs/home_bloc/home_bloc.dart';
import '../../blocs/home_bloc/home_state_event.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  // Use cities from the existing predefined list
  final List<City> _allCities = City.cities;

  // Mock recent searches
  final List<City> _recent = City.cities.take(3).toList();

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() {
      setState(() {
        _query = _queryController.text;
      });
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _selectCity(City city) {
    // Dispatch event to load new city weather
    context.read<HomeBloc>().add(LoadWeatherEvent(city));
    // Pop back to home
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredCities = _query.isEmpty
        ? <City>[]
        : _allCities
              .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 24.0,
                top: 16.0,
                bottom: 24.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Shahar qidiring',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                    child: TextField(
                      controller: _queryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Shahar qidiring...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x),
                                color: isDark ? Colors.white54 : Colors.black54,
                                onPressed: () => _queryController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _selectCity(_allCities[0]);
                      },
                      icon: const Icon(LucideIcons.mapPin, color: Colors.white),
                      label: const Text(
                        'Joriy joylashuvni aniqlash',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content Area
            Expanded(
              child: _query.isNotEmpty
                  ? _buildSearchResults(filteredCities, isDark)
                  : _buildDefaultView(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<City> filteredCities, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        const Text(
          'NATIJALAR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        if (filteredCities.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'Shahar topilmadi',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ...filteredCities.map(
          (city) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => _selectCity(city),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.mapPin, color: Color(0xFF29B6F6)),
                    const SizedBox(width: 16),
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        // Recent Searches
        const Text(
          'YAQINDA QIDIRILGAN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ..._recent.map(
          (city) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => _selectCity(city),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock, color: Colors.grey),
                    const SizedBox(width: 16),
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Popular Cities
        const Text(
          'OMMABOP SHAHARLAR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allCities
              .take(6)
              .map(
                (city) => InkWell(
                  onTap: () => _selectCity(city),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white,
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
