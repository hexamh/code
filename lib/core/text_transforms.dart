/// Text transformation utilities for the code editor.
class TextTransforms {
  TextTransforms._();

  /// Converts text to UPPERCASE.
  static String toUpperCase(String text) => text.toUpperCase();

  /// Converts text to lowercase.
  static String toLowerCase(String text) => text.toLowerCase();

  /// Converts text to Title Case.
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Converts camelCase to snake_case.
  static String toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (m) => '_${m.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'^_'), '');
  }

  /// Converts snake_case to camelCase.
  static String toCamelCase(String text) {
    final parts = text.split('_');
    if (parts.length <= 1) return text;
    return parts.first +
        parts.skip(1).map((p) {
          if (p.isEmpty) return p;
          return p[0].toUpperCase() + p.substring(1);
        }).join();
  }

  /// Reverses each line in the text.
  static String reverseLines(String text) {
    return text
        .split('\n')
        .map((line) => String.fromCharCodes(line.runes.toList().reversed))
        .join('\n');
  }

  /// Sorts lines alphabetically.
  static String sortLines(String text, {bool descending = false}) {
    final lines = text.split('\n');
    lines.sort();
    if (descending) {
      return lines.reversed.join('\n');
    }
    return lines.join('\n');
  }

  /// Removes duplicate lines.
  static String removeDuplicateLines(String text) {
    final lines = text.split('\n');
    final seen = <String>{};
    final unique = <String>[];
    for (final line in lines) {
      if (seen.add(line)) {
        unique.add(line);
      }
    }
    return unique.join('\n');
  }

  /// Trims trailing whitespace from each line.
  static String trimTrailingWhitespace(String text) {
    return text.split('\n').map((line) => line.trimRight()).join('\n');
  }

  /// Adds a line number prefix to each line.
  static String addLineNumbers(String text) {
    final lines = text.split('\n');
    final width = lines.length.toString().length;
    return lines
        .asMap()
        .entries
        .map((e) => '${(e.key + 1).toString().padLeft(width)}: ${e.value}')
        .join('\n');
  }

  /// Joins all lines into a single line separated by spaces.
  static String joinLines(String text) {
    return text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).join(' ');
  }
}
