import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/data/models/editor_file.dart';
import 'package:myapp/domain/syntax/language_registry.dart';

/// Persists open tabs state so they can be restored on app restart.
class SessionService {
  static const _key = 'session_open_tabs';
  static const _activeTabKey = 'session_active_tab';

  /// Saves the current session (list of open files and active tab).
  Future<void> saveSession(List<EditorFile> files, int activeTabIndex) async {
    final prefs = await SharedPreferences.getInstance();

    final sessionData = files.map((f) => {
      'uri': f.uri,
      'displayName': f.displayName,
      'content': f.content,
      'language': f.language.name,
      'isDirty': f.isDirty,
      'encoding': f.encoding,
    }).toList();

    await prefs.setString(_key, jsonEncode(sessionData));
    await prefs.setInt(_activeTabKey, activeTabIndex);
  }

  /// Restores the last session. Returns null if no session exists.
  Future<({List<EditorFile> files, int activeTab})?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    try {
      final List<dynamic> sessionData = jsonDecode(jsonString);
      if (sessionData.isEmpty) return null;

      final files = sessionData.map((item) {
        final map = item as Map<String, dynamic>;
        final languageName = map['language'] as String? ?? 'plainText';
        SyntaxLanguage language;
        try {
          language = SyntaxLanguage.values.firstWhere(
            (l) => l.name == languageName,
            orElse: () => SyntaxLanguage.plainText,
          );
        } catch (_) {
          language = SyntaxLanguage.plainText;
        }

        return EditorFile(
          uri: map['uri'] as String?,
          displayName: map['displayName'] as String? ?? 'Untitled',
          content: map['content'] as String? ?? '',
          language: language,
          isDirty: map['isDirty'] as bool? ?? false,
          encoding: map['encoding'] as String? ?? 'UTF-8',
        );
      }).toList();

      final activeTab = prefs.getInt(_activeTabKey) ?? 0;

      return (files: files, activeTab: activeTab.clamp(0, files.length - 1));
    } catch (_) {
      return null;
    }
  }

  /// Clears the saved session.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_activeTabKey);
  }
}
