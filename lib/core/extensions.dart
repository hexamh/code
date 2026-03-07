import 'package:flutter/material.dart';

/// Extension methods on [String] for file and text utilities.
extension StringExtensions on String {
  /// Extracts the file extension from a path/filename (e.g., "main.dart" → "dart").
  String get fileExtension {
    final dot = lastIndexOf('.');
    if (dot < 0 || dot == length - 1) return '';
    return substring(dot + 1).toLowerCase();
  }

  /// Extracts the filename from a full path.
  String get fileName {
    final sep = lastIndexOf(RegExp(r'[/\\]'));
    if (sep < 0) return this;
    return substring(sep + 1);
  }

  /// Truncates to [maxLength] characters, adding "…" if necessary.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 1)}…';
  }
}

/// Extension methods on [BuildContext] for quick theme access.
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
