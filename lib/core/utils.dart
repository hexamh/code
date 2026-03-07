import 'dart:convert';
import 'dart:typed_data';

/// Utility functions for the Code Editor.
class AppUtils {
  AppUtils._();

  /// Converts byte count to a human-readable size string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Attempts to decode bytes as UTF-8, falling back to Latin-1.
  static ({String content, String encoding}) decodeBytes(Uint8List bytes) {
    try {
      final content = utf8.decode(bytes);
      return (content: content, encoding: 'UTF-8');
    } catch (_) {
      final content = latin1.decode(bytes);
      return (content: content, encoding: 'Latin-1');
    }
  }

  /// Counts lines in a string.
  static int countLines(String text) {
    if (text.isEmpty) return 1;
    int count = 1;
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 10) count++; // '\n'
    }
    return count;
  }

  /// Gets line and column number from a cursor offset in text.
  static ({int line, int column}) getCursorPosition(String text, int offset) {
    if (offset <= 0 || text.isEmpty) return (line: 1, column: 1);
    final clampedOffset = offset.clamp(0, text.length);
    int line = 1;
    int lastNewline = -1;
    for (int i = 0; i < clampedOffset; i++) {
      if (text.codeUnitAt(i) == 10) {
        line++;
        lastNewline = i;
      }
    }
    return (line: line, column: clampedOffset - lastNewline);
  }
}
