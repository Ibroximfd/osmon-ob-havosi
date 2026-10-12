/// Typed reads over decoded JSON. Each throws [FormatException] on a shape
/// mismatch, which `guard` turns into a `ServerFailure` — so a contract break
/// never surfaces as a TypeError crash.
extension JsonReader on Map<String, dynamic> {
  Map<String, dynamic> object(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    throw FormatException('expected object at "$key"');
  }

  Map<String, dynamic>? objectOrNull(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  List<dynamic> list(String key) {
    final value = this[key];
    if (value is List<dynamic>) return value;
    throw FormatException('expected list at "$key"');
  }

  List<dynamic>? listOrNull(String key) {
    final value = this[key];
    return value is List<dynamic> ? value : null;
  }

  double number(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    throw FormatException('expected number at "$key"');
  }

  double? numberOrNull(String key) {
    final value = this[key];
    return value is num ? value.toDouble() : null;
  }

  String text(String key) {
    final value = this[key];
    if (value is String) return value;
    throw FormatException('expected string at "$key"');
  }

  String? textOrNull(String key) {
    final value = this[key];
    return value is String ? value : null;
  }
}

/// Element access for the parallel arrays Open-Meteo returns.
extension JsonSeries on List<dynamic> {
  double numberAt(int index) {
    final value = this[index];
    if (value is num) return value.toDouble();
    throw FormatException('expected number at index $index');
  }

  double? numberOrNullAt(int index) {
    if (index >= length) return null;
    final value = this[index];
    return value is num ? value.toDouble() : null;
  }

  String textAt(int index) {
    final value = this[index];
    if (value is String) return value;
    throw FormatException('expected string at index $index');
  }
}
