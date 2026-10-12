import 'app_settings.dart';

/// Local preferences. Reads are synchronous because the store is loaded
/// before the first frame; writes cannot fail in an expected way, so they
/// return plain futures rather than `Either`.
abstract interface class SettingsRepository {
  AppSettings get current;

  Stream<AppSettings> watch();

  Future<void> save(AppSettings settings);
}
