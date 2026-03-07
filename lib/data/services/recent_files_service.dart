import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/core/constants.dart';

/// A recently opened file entry.
class RecentFile {
  final String name;
  final String uri;
  final DateTime timestamp;

  const RecentFile({
    required this.name,
    required this.uri,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        name: json['name'] as String,
        uri: json['uri'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Service for persisting recently opened files.
class RecentFilesService {
  static const _key = 'recent_files';

  /// Retrieves the list of recently opened files, most recent first.
  Future<List<RecentFile>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((e) => RecentFile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Adds a file to the recent files list or moves it to the top.
  Future<void> addRecentFile(String name, String uri) async {
    final files = await getRecentFiles();

    // Remove duplicate if exists
    files.removeWhere((f) => f.uri == uri);

    // Insert at the beginning
    files.insert(
      0,
      RecentFile(name: name, uri: uri, timestamp: DateTime.now()),
    );

    // Trim to max count
    if (files.length > AppConstants.maxRecentFiles) {
      files.removeRange(AppConstants.maxRecentFiles, files.length);
    }

    await _save(files);
  }

  /// Removes a file from the recent files list.
  Future<void> removeRecentFile(String uri) async {
    final files = await getRecentFiles();
    files.removeWhere((f) => f.uri == uri);
    await _save(files);
  }

  /// Clears all recent files.
  Future<void> clearRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(List<RecentFile> files) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(files.map((f) => f.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
