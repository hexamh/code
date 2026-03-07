import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/models/search_query.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';

/// Whether the search bar is currently visible.
final searchVisibleProvider = StateProvider<bool>((ref) => false);

/// The current search query state.
final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, SearchQuery>((ref) {
  return SearchQueryNotifier();
});

/// Computed search results (match ranges) for the active file.
final searchResultsProvider =
    Provider<List<({int start, int end})>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final activeFile = ref.watch(activeFileProvider);
  if (activeFile == null || query.query.isEmpty) return [];
  return query.findMatches(activeFile.content);
});

class SearchQueryNotifier extends StateNotifier<SearchQuery> {
  SearchQueryNotifier() : super(const SearchQuery());

  void setQuery(String query) {
    state = state.copyWith(query: query, currentMatchIndex: 0);
  }

  void setReplacement(String replacement) {
    state = state.copyWith(replacement: replacement);
  }

  void toggleRegex() {
    state = state.copyWith(isRegex: !state.isRegex, currentMatchIndex: 0);
  }

  void toggleCaseSensitive() {
    state = state.copyWith(
        isCaseSensitive: !state.isCaseSensitive, currentMatchIndex: 0);
  }

  void toggleWholeWord() {
    state =
        state.copyWith(isWholeWord: !state.isWholeWord, currentMatchIndex: 0);
  }

  void nextMatch(int totalMatches) {
    if (totalMatches == 0) return;
    final next = (state.currentMatchIndex + 1) % totalMatches;
    state = state.copyWith(currentMatchIndex: next, totalMatches: totalMatches);
  }

  void previousMatch(int totalMatches) {
    if (totalMatches == 0) return;
    final prev = (state.currentMatchIndex - 1 + totalMatches) % totalMatches;
    state = state.copyWith(currentMatchIndex: prev, totalMatches: totalMatches);
  }

  void clear() {
    state = const SearchQuery();
  }
}
