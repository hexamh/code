import 'package:highlight/languages/all.dart';
import 'package:highlight/highlight_core.dart';

/// Enum representing all supported syntax languages.
enum SyntaxLanguage {
  plainText('Plain Text', []),
  dart('Dart', ['dart']),
  python('Python', ['py', 'pyw']),
  javascript('JavaScript', ['js', 'mjs', 'cjs']),
  typescript('TypeScript', ['ts']),
  jsx('JSX', ['jsx']),
  tsx('TSX', ['tsx']),
  java('Java', ['java']),
  kotlin('Kotlin', ['kt', 'kts']),
  c('C', ['c', 'h']),
  cpp('C++', ['cpp', 'hpp', 'cc', 'cxx', 'hh']),
  csharp('C#', ['cs']),
  go('Go', ['go']),
  rust('Rust', ['rs']),
  swift('Swift', ['swift']),
  ruby('Ruby', ['rb']),
  php('PHP', ['php']),
  html('HTML', ['html', 'htm']),
  css('CSS', ['css']),
  scss('SCSS', ['scss']),
  json('JSON', ['json']),
  xml('XML', ['xml', 'svg', 'plist']),
  yaml('YAML', ['yaml', 'yml']),
  markdown('Markdown', ['md', 'markdown']),
  sql('SQL', ['sql']),
  shell('Shell', ['sh', 'bash', 'zsh']),
  dockerfile('Dockerfile', ['dockerfile']),
  r('R', ['r']),
  lua('Lua', ['lua']),
  perl('Perl', ['pl', 'pm']),
  groovy('Groovy', ['groovy', 'gradle']),
  properties('Properties', ['properties', 'ini', 'cfg', 'conf', 'env']),
  toml('TOML', ['toml']);

  final String displayName;
  final List<String> extensions;

  const SyntaxLanguage(this.displayName, this.extensions);
}

/// Maps file extensions and names to highlight language modes.
class LanguageRegistry {
  LanguageRegistry._();

  static final Map<String, SyntaxLanguage> _extensionMap = _buildExtensionMap();
  static bool _initialized = false;

  /// Builds the reverse lookup map from extension → SyntaxLanguage.
  static Map<String, SyntaxLanguage> _buildExtensionMap() {
    final map = <String, SyntaxLanguage>{};
    for (final lang in SyntaxLanguage.values) {
      for (final ext in lang.extensions) {
        map[ext] = lang;
      }
    }
    return map;
  }

  /// Maps [SyntaxLanguage] enum values to highlight language IDs.
  static const Map<SyntaxLanguage, String> _highlightIds = {
    SyntaxLanguage.dart: 'dart',
    SyntaxLanguage.python: 'python',
    SyntaxLanguage.javascript: 'javascript',
    SyntaxLanguage.typescript: 'typescript',
    SyntaxLanguage.jsx: 'javascript',
    SyntaxLanguage.tsx: 'typescript',
    SyntaxLanguage.java: 'java',
    SyntaxLanguage.kotlin: 'kotlin',
    SyntaxLanguage.c: 'c',
    SyntaxLanguage.cpp: 'cpp',
    SyntaxLanguage.csharp: 'cs',
    SyntaxLanguage.go: 'go',
    SyntaxLanguage.rust: 'rust',
    SyntaxLanguage.swift: 'swift',
    SyntaxLanguage.ruby: 'ruby',
    SyntaxLanguage.php: 'php',
    SyntaxLanguage.html: 'xml',
    SyntaxLanguage.css: 'css',
    SyntaxLanguage.scss: 'scss',
    SyntaxLanguage.json: 'json',
    SyntaxLanguage.xml: 'xml',
    SyntaxLanguage.yaml: 'yaml',
    SyntaxLanguage.markdown: 'markdown',
    SyntaxLanguage.sql: 'sql',
    SyntaxLanguage.shell: 'bash',
    SyntaxLanguage.dockerfile: 'dockerfile',
    SyntaxLanguage.r: 'r',
    SyntaxLanguage.lua: 'lua',
    SyntaxLanguage.perl: 'perl',
    SyntaxLanguage.groovy: 'groovy',
    SyntaxLanguage.properties: 'ini',
    SyntaxLanguage.toml: 'ini',
  };

  /// Registers all highlight languages. Call once at app start.
  static void initialize() {
    if (_initialized) return;
    allLanguages.forEach((name, mode) {
      highlight.registerLanguage(name, mode);
    });
    _initialized = true;
  }

  /// Detects the [SyntaxLanguage] from a file name.
  static SyntaxLanguage detectFromFileName(String fileName) {
    // Handle special filenames first
    final lowerName = fileName.toLowerCase();
    if (lowerName == 'dockerfile') return SyntaxLanguage.dockerfile;
    if (lowerName == 'makefile') return SyntaxLanguage.shell;
    if (lowerName.startsWith('.env')) return SyntaxLanguage.properties;
    if (lowerName == '.gitignore') return SyntaxLanguage.shell;
    if (lowerName == '.editorconfig') return SyntaxLanguage.properties;

    // Extension-based detection
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return SyntaxLanguage.plainText;
    final ext = fileName.substring(dot + 1).toLowerCase();
    return _extensionMap[ext] ?? SyntaxLanguage.plainText;
  }

  /// Gets the highlight language ID string for a [SyntaxLanguage].
  static String? getHighlightId(SyntaxLanguage language) {
    return _highlightIds[language];
  }

  /// Returns all languages sorted by display name for the language picker.
  static List<SyntaxLanguage> get allLanguages_ {
    return SyntaxLanguage.values.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }
}
