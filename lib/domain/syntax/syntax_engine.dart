import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/highlight_core.dart';
import 'package:myapp/domain/syntax/language_registry.dart';

/// Wraps the highlight parsing engine with performance optimizations.
class SyntaxEngine {
  SyntaxEngine._();

  /// Parses source code and returns a [Result] containing highlighted spans.
  /// Uses the highlight package for tokenization.
  static Result? parse(String code, SyntaxLanguage language) {
    if (language == SyntaxLanguage.plainText) return null;

    final highlightId = LanguageRegistry.getHighlightId(language);
    if (highlightId == null) return null;

    try {
      return highlight.parse(code, language: highlightId);
    } catch (_) {
      return null;
    }
  }

  /// Creates a [CodeController] configured for the given language.
  static CodeController createController({
    required String text,
    required SyntaxLanguage language,
  }) {
    final highlightId = LanguageRegistry.getHighlightId(language);
    Mode? mode;
    if (highlightId != null) {
      mode = highlight.getLanguage(highlightId);
    }

    return CodeController(
      text: text,
      language: mode,
    );
  }
}
