import 'package:myapp/domain/syntax/language_registry.dart';

/// Represents an open file in the editor.
class EditorFile {
  final String? uri;
  final String displayName;
  final String content;
  final SyntaxLanguage language;
  final bool isDirty;
  final String encoding;

  const EditorFile({
    this.uri,
    required this.displayName,
    required this.content,
    this.language = SyntaxLanguage.plainText,
    this.isDirty = false,
    this.encoding = 'UTF-8',
  });

  /// Creates a new untitled document.
  factory EditorFile.untitled({int number = 1}) {
    return EditorFile(
      displayName: 'Untitled-$number',
      content: '',
      language: SyntaxLanguage.plainText,
    );
  }

  EditorFile copyWith({
    String? uri,
    String? displayName,
    String? content,
    SyntaxLanguage? language,
    bool? isDirty,
    String? encoding,
  }) {
    return EditorFile(
      uri: uri ?? this.uri,
      displayName: displayName ?? this.displayName,
      content: content ?? this.content,
      language: language ?? this.language,
      isDirty: isDirty ?? this.isDirty,
      encoding: encoding ?? this.encoding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorFile &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          displayName == other.displayName &&
          isDirty == other.isDirty;

  @override
  int get hashCode => Object.hash(uri, displayName, isDirty);
}
