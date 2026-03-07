import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/data/models/editor_settings.dart';

/// Service for persisting user editor settings.
class SettingsService {
  static const _key = 'editor_settings';

  /// Loads settings from SharedPreferences.
  Future<EditorSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return const EditorSettings();

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return EditorSettings.fromJson(json);
    } catch (_) {
      return const EditorSettings();
    }
  }

  /// Saves settings to SharedPreferences.
  Future<void> saveSettings(EditorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_key, jsonString);
  }
}
