import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/models/editor_settings.dart';
import 'package:myapp/data/services/settings_service.dart';
import 'package:myapp/domain/editor_themes.dart';

/// Service provider for settings persistence.
final settingsServiceProvider =
    Provider<SettingsService>((ref) => SettingsService());

/// The main settings provider — async because it loads from SharedPreferences.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, EditorSettings>(
        SettingsNotifier.new);

/// Derived provider for the theme mode (used by MaterialApp).
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.valueOrNull?.themeMode ?? ThemeMode.system;
});

/// Derived provider for the current editor syntax theme.
final editorThemeProvider = Provider<EditorTheme>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.valueOrNull?.editorTheme ?? EditorTheme.monokaiSublime;
});

class SettingsNotifier extends AsyncNotifier<EditorSettings> {
  @override
  Future<EditorSettings> build() async {
    final service = ref.read(settingsServiceProvider);
    return service.loadSettings();
  }

  Future<void> updateSettings(EditorSettings settings) async {
    final service = ref.read(settingsServiceProvider);
    await service.saveSettings(settings);
    state = AsyncData(settings);
  }

  Future<void> setFontSize(double size) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(fontSize: size));
  }

  Future<void> setFontFamily(String family) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(fontFamily: family));
  }

  Future<void> setTabWidth(int width) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(tabWidth: width));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(themeMode: mode));
  }

  Future<void> setEditorTheme(EditorTheme theme) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(editorThemeName: theme.name));
  }

  Future<void> setAutoSave(bool enabled) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(autoSaveEnabled: enabled));
  }

  Future<void> setAutoSaveInterval(int seconds) async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(autoSaveIntervalSeconds: seconds));
  }

  Future<void> toggleWordWrap() async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(wordWrap: !current.wordWrap));
  }

  Future<void> toggleLineNumbers() async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(
        current.copyWith(showLineNumbers: !current.showLineNumbers));
  }

  Future<void> toggleMinimap() async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(showMinimap: !current.showMinimap));
  }

  Future<void> toggleAutoIndent() async {
    final current = state.valueOrNull ?? const EditorSettings();
    await updateSettings(current.copyWith(autoIndent: !current.autoIndent));
  }
}
