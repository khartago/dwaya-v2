// lib/extensions/string_extension.dart
extension StringCasingExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
