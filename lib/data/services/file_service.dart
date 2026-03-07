import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/utils.dart';
import 'package:myapp/data/models/editor_file.dart';
import 'package:myapp/domain/syntax/language_registry.dart';
import 'package:myapp/core/extensions.dart';

/// Service for file I/O operations using SAF (Scoped Storage).
class FileService {
  /// Opens a file using the system file picker (SAF on Android 10+).
  /// Returns an [EditorFile] with the loaded content, or null if cancelled.
  Future<EditorFile?> pickAndOpenFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;
      final name = file.name;

      if (bytes == null) {
        // If bytes not available, try reading from path (Android < 10)
        final path = file.path;
        if (path == null) return null;
        final fileData = await File(path).readAsBytes();
        final decoded = AppUtils.decodeBytes(fileData);
        final language = LanguageRegistry.detectFromFileName(name);
        return EditorFile(
          uri: path,
          displayName: name,
          content: decoded.content,
          language: language,
          encoding: decoded.encoding,
        );
      }

      final decoded = AppUtils.decodeBytes(bytes);
      final language = LanguageRegistry.detectFromFileName(name);

      return EditorFile(
        uri: file.path,
        displayName: name,
        content: decoded.content,
        language: language,
        encoding: decoded.encoding,
      );
    } catch (e) {
      throw FileServiceException('Failed to open file: $e');
    }
  }

  /// Saves content to an existing file path.
  Future<bool> saveFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content, flush: true);
      return true;
    } catch (e) {
      throw FileServiceException('Failed to save file: $e');
    }
  }

  /// Opens a "Save As" dialog and saves content to a new location.
  /// Returns the new file path, or null if cancelled.
  Future<String?> saveFileAs(String content, String suggestedName) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save As',
        fileName: suggestedName,
      );

      if (result == null) return null;

      final file = File(result);
      await file.writeAsString(content, flush: true);
      return result;
    } catch (e) {
      throw FileServiceException('Failed to save file: $e');
    }
  }

  /// Creates a new untitled file in memory.
  EditorFile createNewFile(int untitledCount) {
    return EditorFile.untitled(number: untitledCount);
  }

  /// Reads a file from a known path (e.g., for intent-opened files).
  Future<EditorFile?> openFromPath(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final decoded = AppUtils.decodeBytes(bytes);
      final name = path.fileName;
      final language = LanguageRegistry.detectFromFileName(name);

      return EditorFile(
        uri: path,
        displayName: name,
        content: decoded.content,
        language: language,
        encoding: decoded.encoding,
      );
    } catch (e) {
      throw FileServiceException('Failed to open file from path: $e');
    }
  }
}

/// Exception thrown by [FileService] operations.
class FileServiceException implements Exception {
  final String message;
  const FileServiceException(this.message);

  @override
  String toString() => 'FileServiceException: $message';
}
