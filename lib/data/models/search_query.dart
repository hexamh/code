/// Model for search & replace state.
class SearchQuery {
  final String query;
  final String replacement;
  final bool isRegex;
  final bool isCaseSensitive;
  final bool isWholeWord;
  final int currentMatchIndex;
  final int totalMatches;

  const SearchQuery({
    this.query = '',
    this.replacement = '',
    this.isRegex = false,
    this.isCaseSensitive = false,
    this.isWholeWord = false,
    this.currentMatchIndex = -1,
    this.totalMatches = 0,
  });

  SearchQuery copyWith({
    String? query,
    String? replacement,
    bool? isRegex,
    bool? isCaseSensitive,
    bool? isWholeWord,
    int? currentMatchIndex,
    int? totalMatches,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      replacement: replacement ?? this.replacement,
      isRegex: isRegex ?? this.isRegex,
      isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
      isWholeWord: isWholeWord ?? this.isWholeWord,
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      totalMatches: totalMatches ?? this.totalMatches,
    );
  }

  /// Builds a [RegExp] from the current query settings.
  RegExp? toRegExp() {
    if (query.isEmpty) return null;
    try {
      String pattern = isRegex ? query : RegExp.escape(query);
      if (isWholeWord) {
        pattern = '\\b$pattern\\b';
      }
      return RegExp(pattern, caseSensitive: isCaseSensitive);
    } catch (_) {
      return null;
    }
  }

  /// Finds all match ranges in the given [text].
  List<({int start, int end})> findMatches(String text) {
    final regex = toRegExp();
    if (regex == null) return [];
    return regex
        .allMatches(text)
        .map((m) => (start: m.start, end: m.end))
        .toList();
  }
}
