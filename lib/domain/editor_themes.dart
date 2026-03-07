import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:flutter_highlight/themes/solarized-dark.dart';
import 'package:flutter_highlight/themes/solarized-light.dart';
import 'package:flutter_highlight/themes/nord.dart';
import 'package:flutter_highlight/themes/ocean.dart';
import 'package:flutter_highlight/themes/tomorrow-night.dart';
import 'package:flutter_highlight/themes/tomorrow.dart';
import 'package:flutter_highlight/themes/dark.dart';

/// Enum of available editor syntax themes.
enum EditorTheme {
  monokaiSublime('Monokai Sublime', true),
  atomOneDark('Atom One Dark', true),
  atomOneLight('Atom One Light', false),
  github('GitHub', false),
  dracula('Dracula', true),
  vs('Visual Studio', false),
  vs2015('VS 2015', true),
  androidStudio('Android Studio', true),
  solarizedDark('Solarized Dark', true),
  solarizedLight('Solarized Light', false),
  nord('Nord', true),
  ocean('Ocean', true),
  tomorrowNight('Tomorrow Night', true),
  tomorrow('Tomorrow', false),
  dark('Dark', true);

  final String displayName;
  final bool isDark;

  const EditorTheme(this.displayName, this.isDark);

  /// Returns the theme map for flutter_highlight.
  Map<String, TextStyle> get themeData {
    return switch (this) {
      EditorTheme.monokaiSublime => monokaiSublimeTheme,
      EditorTheme.atomOneDark => atomOneDarkTheme,
      EditorTheme.atomOneLight => atomOneLightTheme,
      EditorTheme.github => githubTheme,
      EditorTheme.dracula => draculaTheme,
      EditorTheme.vs => vsTheme,
      EditorTheme.vs2015 => vs2015Theme,
      EditorTheme.androidStudio => androidstudioTheme,
      EditorTheme.solarizedDark => solarizedDarkTheme,
      EditorTheme.solarizedLight => solarizedLightTheme,
      EditorTheme.nord => nordTheme,
      EditorTheme.ocean => oceanTheme,
      EditorTheme.tomorrowNight => tomorrowNightTheme,
      EditorTheme.tomorrow => tomorrowTheme,
      EditorTheme.dark => darkTheme,
    };
  }

  /// Returns the background color from the theme.
  Color get backgroundColor {
    final root = themeData['root'];
    return root?.backgroundColor ?? (isDark ? Colors.black : Colors.white);
  }

  /// Returns themes appropriate for the current brightness.
  static List<EditorTheme> themesForBrightness(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return values.where((t) => t.isDark).toList();
    }
    return values.where((t) => !t.isDark).toList();
  }

  /// Returns all themes sorted by name.
  static List<EditorTheme> get allSorted =>
      values.toList()..sort((a, b) => a.displayName.compareTo(b.displayName));
}
