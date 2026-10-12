/// Asks the platform for permission to post notifications.
abstract interface class NotificationPermissions {
  /// True when notifications may be shown (granted now or earlier).
  Future<bool> request();

  /// Opens the app's system settings, where a permission refused for good
  /// can still be granted.
  Future<void> openSettings();
}
