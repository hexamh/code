import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/models/editor_file.dart';
import 'package:myapp/data/services/file_service.dart';
import 'package:myapp/data/services/recent_files_service.dart';
import 'package:myapp/domain/syntax/language_registry.dart';

/// Service providers
final fileServiceProvider = Provider<FileService>((ref) => FileService());
final recentFilesServiceProvider =
    Provider<RecentFilesService>((ref) => RecentFilesService());

/// The list of currently open files (tabs).
final openFilesProvider =
    StateNotifierProvider<OpenFilesNotifier, List<EditorFile>>((ref) {
  return OpenFilesNotifier(ref);
});

/// Index of the currently active tab.
final activeTabIndexProvider = StateProvider<int>((ref) => 0);

/// Derived provider for the currently active file.
final activeFileProvider = Provider<EditorFile?>((ref) {
  final files = ref.watch(openFilesProvider);
  final index = ref.watch(activeTabIndexProvider);
  if (files.isEmpty || index < 0 || index >= files.length) return null;
  return files[index];
});

/// Counter for untitled files.
final _untitledCounterProvider = StateProvider<int>((ref) => 1);

class OpenFilesNotifier extends StateNotifier<List<EditorFile>> {
  final Ref ref;

  OpenFilesNotifier(this.ref) : super([EditorFile.untitled(number: 1)]);

  /// Opens a file via the system picker.
  Future<bool> openFile() async {
    final fileService = ref.read(fileServiceProvider);
    final recentFilesService = ref.read(recentFilesServiceProvider);

    try {
      final file = await fileService.pickAndOpenFile();
      if (file == null) return false;

      // Check if already open
      final existingIndex =
          state.indexWhere((f) => f.uri != null && f.uri == file.uri);
      if (existingIndex >= 0) {
        ref.read(activeTabIndexProvider.notifier).state = existingIndex;
        return true;
      }

      state = [...state, file];
      ref.read(activeTabIndexProvider.notifier).state = state.length - 1;

      // Add to recent files
      if (file.uri != null) {
        await recentFilesService.addRecentFile(file.displayName, file.uri!);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Creates a new untitled tab.
  void createNewFile() {
    final counter = ref.read(_untitledCounterProvider);
    ref.read(_untitledCounterProvider.notifier).state = counter + 1;

    final newFile = EditorFile.untitled(number: counter);
    state = [...state, newFile];
    ref.read(activeTabIndexProvider.notifier).state = state.length - 1;
  }

  /// Closes a file tab at the given index.
  void closeFile(int index) {
    if (index < 0 || index >= state.length) return;

    final newList = [...state];
    newList.removeAt(index);

    // If closing the last tab, create a new untitled
    if (newList.isEmpty) {
      final counter = ref.read(_untitledCounterProvider);
      ref.read(_untitledCounterProvider.notifier).state = counter + 1;
      newList.add(EditorFile.untitled(number: counter));
    }

    state = newList;

    // Adjust active tab index
    final currentIndex = ref.read(activeTabIndexProvider);
    if (currentIndex >= newList.length) {
      ref.read(activeTabIndexProvider.notifier).state = newList.length - 1;
    } else if (currentIndex > index) {
      ref.read(activeTabIndexProvider.notifier).state = currentIndex - 1;
    }
  }

  /// Updates the content of a file at the given index.
  void updateContent(int index, String content) {
    if (index < 0 || index >= state.length) return;

    final file = state[index];
    final updated = file.copyWith(content: content, isDirty: true);

    final newList = [...state];
    newList[index] = updated;
    state = newList;
  }

  /// Changes the language of a file at the given index.
  void changeLanguage(int index, SyntaxLanguage language) {
    if (index < 0 || index >= state.length) return;

    final file = state[index];
    final updated = file.copyWith(language: language);

    final newList = [...state];
    newList[index] = updated;
    state = newList;
  }

  /// Saves the currently active file.
  Future<bool> saveActiveFile() async {
    final index = ref.read(activeTabIndexProvider);
    if (index < 0 || index >= state.length) return false;

    final file = state[index];
    final fileService = ref.read(fileServiceProvider);
    final recentFilesService = ref.read(recentFilesServiceProvider);

    try {
      if (file.uri != null) {
        // Save to existing path
        await fileService.saveFile(file.uri!, file.content);
      } else {
        // Save As for new files
        final newPath =
            await fileService.saveFileAs(file.content, file.displayName);
        if (newPath == null) return false;

        // Update file with the new path
        final updatedName = newPath.split(RegExp(r'[/\\]')).last;
        final updatedFile = file.copyWith(
          uri: newPath,
          displayName: updatedName,
          isDirty: false,
          language: LanguageRegistry.detectFromFileName(updatedName),
        );

        final newList = [...state];
        newList[index] = updatedFile;
        state = newList;

        await recentFilesService.addRecentFile(updatedName, newPath);
        return true;
      }

      // Mark as saved
      final updated = file.copyWith(isDirty: false);
      final newList = [...state];
      newList[index] = updated;
      state = newList;

      if (file.uri != null) {
        await recentFilesService.addRecentFile(file.displayName, file.uri!);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Closes all files except the one at the given index.
  void closeOthers(int keepIndex) {
    if (keepIndex < 0 || keepIndex >= state.length) return;
    state = [state[keepIndex]];
    ref.read(activeTabIndexProvider.notifier).state = 0;
  }

  /// Closes all files and creates a new untitled tab.
  void closeAll() {
    final counter = ref.read(_untitledCounterProvider);
    ref.read(_untitledCounterProvider.notifier).state = counter + 1;
    state = [EditorFile.untitled(number: counter)];
    ref.read(activeTabIndexProvider.notifier).state = 0;
  }
}
