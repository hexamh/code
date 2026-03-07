import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';

/// Provider for the auto-save service.
final autoSaveProvider = Provider<AutoSaveService>((ref) {
  final service = AutoSaveService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Whether auto-save is currently enabled.
final autoSaveEnabledProvider = StateProvider<bool>((ref) => true);

/// Auto-save interval in seconds.
final autoSaveIntervalProvider = StateProvider<int>((ref) => 30);

/// Service that automatically saves dirty files on a configurable timer.
class AutoSaveService {
  final Ref _ref;
  Timer? _timer;
  bool _isRunning = false;

  AutoSaveService(this._ref) {
    _startWatching();
  }

  void _startWatching() {
    _timer?.cancel();
    final enabled = _ref.read(autoSaveEnabledProvider);
    if (!enabled) return;

    final interval = _ref.read(autoSaveIntervalProvider);
    _timer = Timer.periodic(Duration(seconds: interval), (_) => _autoSave());
    _isRunning = true;
  }

  Future<void> _autoSave() async {
    if (!_ref.read(autoSaveEnabledProvider)) return;

    final files = _ref.read(openFilesProvider);
    final notifier = _ref.read(openFilesProvider.notifier);

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      // Only auto-save files that have a URI (already saved once) and are dirty
      if (file.isDirty && file.uri != null) {
        try {
          final fileService = _ref.read(fileServiceProvider);
          await fileService.saveFile(file.uri!, file.content);
          // Mark as clean after auto-save
          notifier.updateContent(i, file.content);
        } catch (_) {
          // Silently fail on auto-save — user can manually save
        }
      }
    }
  }

  /// Restarts the auto-save timer (call when settings change).
  void restart() {
    _timer?.cancel();
    _startWatching();
  }

  /// Triggers an immediate auto-save.
  Future<void> saveNow() => _autoSave();

  void dispose() {
    _timer?.cancel();
    _isRunning = false;
  }

  bool get isRunning => _isRunning;
}
