abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String radar = '/radar';
  static const String map = '/map';
  static const String health = '/health';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String prayer = '/prayer';
  static const String field = '/field';
  static const String route = '/route';
  static const String alerts = '/alerts';
  static const String chat = '/chat';
  static const String photo = '/photo';

  /// Search that hands the chosen place back instead of switching city.
  static const String pickPlace = '/search?pick=1';
}
