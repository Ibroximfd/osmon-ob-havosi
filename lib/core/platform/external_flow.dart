/// Marks moments when the app hands the screen to the system on purpose —
/// the photo picker, a settings screen, the browser, the store. Returning
/// from one is not a "new visit", so the app-open ad must not interrupt it.
abstract final class ExternalFlow {
  static int _active = 0;
  static DateTime? _endedAt;

  /// The foreground event can arrive just after the awaited call returns.
  static const Duration _graceAfterReturn = Duration(seconds: 3);

  static Future<T> run<T>(Future<T> Function() action) async {
    _active++;
    try {
      return await action();
    } finally {
      _active--;
      _endedAt = DateTime.now();
    }
  }

  /// Call before leaving the app without awaiting a result (ad clicks).
  static void markLeaving() =>
      _endedAt = DateTime.now().add(const Duration(minutes: 30));

  static bool get isReturningFromExternal {
    if (_active > 0) return true;
    final ended = _endedAt;
    return ended != null &&
        DateTime.now().difference(ended) < _graceAfterReturn;
  }

  /// Consumes the "returning" state after the app-open decision is made.
  static void clear() => _endedAt = null;
}
