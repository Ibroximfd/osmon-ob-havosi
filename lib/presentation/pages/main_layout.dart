import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/banner_ad_widget.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
                top: 4.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x33000000)
                      : const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedItemColor: const Color(0xFF29B6F6), // accent color
                    unselectedItemColor: isDark
                        ? Colors.white54
                        : Colors.black54,
                    selectedLabelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                    currentIndex: currentIndex,
                    onTap: (index) => _onItemTapped(index, context),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.home),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.home, size: 28),
                        ),
                        label: 'Bosh',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.map),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.map, size: 28),
                        ),
                        label: 'Xarita',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.camera),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.camera, size: 28),
                        ),
                        label: 'AI Foto',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.bell),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.bell, size: 28),
                        ),
                        label: 'Ogohlantirishlar',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.settings),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(LucideIcons.settings, size: 28),
                        ),
                        label: 'Sozlamalar',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(String location) {
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/ai-photo')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/ai-photo');
        break;
      case 3:
        context.go('/alerts');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
