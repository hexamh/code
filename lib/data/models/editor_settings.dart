import 'package:flutter/material.dart';
import 'package:myapp/core/constants.dart';
import 'package:myapp/domain/editor_themes.dart';

/// Represents the editor settings that the user can configure.
class EditorSettings {
  final double fontSize;
  final String fontFamily;
  final int tabWidth;
  final ThemeMode themeMode;
  final bool wordWrap;
  final bool showLineNumbers;
  final bool showMinimap;
  final bool autoIndent;
  final String editorThemeName;
  final bool autoSaveEnabled;
  final int autoSaveIntervalSeconds;

  const EditorSettings({
    this.fontSize = AppConstants.defaultFontSize,
    this.fontFamily = AppConstants.defaultFontFamily,
    this.tabWidth = AppConstants.defaultTabWidth,
    this.themeMode = ThemeMode.system,
    this.wordWrap = AppConstants.defaultWordWrap,
    this.showLineNumbers = AppConstants.defaultShowLineNumbers,
    this.showMinimap = AppConstants.defaultShowMinimap,
    this.autoIndent = AppConstants.defaultAutoIndent,
    this.editorThemeName = 'monokaiSublime',
    this.autoSaveEnabled = true,
    this.autoSaveIntervalSeconds = 30,
  });

  /// Resolves the [EditorTheme] enum from the stored name.
  EditorTheme get editorTheme {
    try {
      return EditorTheme.values.firstWhere((t) => t.name == editorThemeName);
    } catch (_) {
      return EditorTheme.monokaiSublime;
    }
  }

  EditorSettings copyWith({
    double? fontSize,
    String? fontFamily,
    int? tabWidth,
    ThemeMode? themeMode,
    bool? wordWrap,
    bool? showLineNumbers,
    bool? showMinimap,
    bool? autoIndent,
    String? editorThemeName,
    bool? autoSaveEnabled,
    int? autoSaveIntervalSeconds,
  }) {
    return EditorSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      tabWidth: tabWidth ?? this.tabWidth,
      themeMode: themeMode ?? this.themeMode,
      wordWrap: wordWrap ?? this.wordWrap,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      showMinimap: showMinimap ?? this.showMinimap,
      autoIndent: autoIndent ?? this.autoIndent,
      editorThemeName: editorThemeName ?? this.editorThemeName,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      autoSaveIntervalSeconds:
          autoSaveIntervalSeconds ?? this.autoSaveIntervalSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'fontFamily': fontFamily,
        'tabWidth': tabWidth,
        'themeMode': themeMode.index,
        'wordWrap': wordWrap,
        'showLineNumbers': showLineNumbers,
        'showMinimap': showMinimap,
        'autoIndent': autoIndent,
        'editorThemeName': editorThemeName,
        'autoSaveEnabled': autoSaveEnabled,
        'autoSaveIntervalSeconds': autoSaveIntervalSeconds,
      };

  factory EditorSettings.fromJson(Map<String, dynamic> json) {
    return EditorSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ??
          AppConstants.defaultFontSize,
      fontFamily:
          json['fontFamily'] as String? ?? AppConstants.defaultFontFamily,
      tabWidth: json['tabWidth'] as int? ?? AppConstants.defaultTabWidth,
      themeMode: ThemeMode
          .values[(json['themeMode'] as int?) ?? ThemeMode.system.index],
      wordWrap: json['wordWrap'] as bool? ?? AppConstants.defaultWordWrap,
      showLineNumbers: json['showLineNumbers'] as bool? ??
          AppConstants.defaultShowLineNumbers,
      showMinimap:
          json['showMinimap'] as bool? ?? AppConstants.defaultShowMinimap,
      autoIndent:
          json['autoIndent'] as bool? ?? AppConstants.defaultAutoIndent,
      editorThemeName:
          json['editorThemeName'] as String? ?? 'monokaiSublime',
      autoSaveEnabled: json['autoSaveEnabled'] as bool? ?? true,
      autoSaveIntervalSeconds:
          json['autoSaveIntervalSeconds'] as int? ?? 30,
    );
  }
}
