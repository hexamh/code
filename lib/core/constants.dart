/// App-wide constants for the Code Editor.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Code Editor';
  static const String appVersion = '1.0.0';

  // Editor defaults
  static const double defaultFontSize = 14.0;
  static const double minFontSize = 8.0;
  static const double maxFontSize = 32.0;
  static const int defaultTabWidth = 4;
  static const String defaultFontFamily = 'JetBrains Mono';
  static const bool defaultWordWrap = false;
  static const bool defaultShowLineNumbers = true;
  static const bool defaultShowMinimap = true;
  static const bool defaultAutoIndent = true;

  // File handling
  static const int maxRecentFiles = 20;
  static const int largeFileThresholdBytes = 5 * 1024 * 1024; // 5 MB
  static const String defaultEncoding = 'UTF-8';

  // Supported file extensions for the file picker
  static const List<String> supportedExtensions = [
    'dart', 'py', 'js', 'ts', 'jsx', 'tsx',
    'java', 'kt', 'kts',
    'c', 'h', 'cpp', 'hpp', 'cc', 'cxx',
    'cs',
    'go',
    'rs',
    'swift',
    'rb',
    'php',
    'html', 'htm',
    'css', 'scss', 'sass', 'less',
    'json',
    'xml', 'svg',
    'yaml', 'yml',
    'md', 'markdown',
    'sql',
    'sh', 'bash', 'zsh',
    'dockerfile',
    'txt', 'log', 'csv', 'ini', 'cfg', 'conf',
    'env', 'gitignore', 'editorconfig',
    'gradle', 'properties',
    'toml',
    'r',
    'lua',
    'pl', 'pm',
  ];
}
