import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight_core.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/data/models/editor_settings.dart';
import 'package:myapp/domain/syntax/language_registry.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';
import 'package:myapp/presentation/providers/settings_providers.dart';

/// Core code editor widget wrapping flutter_code_editor with syntax highlighting.
class CodeEditorWidget extends ConsumerStatefulWidget {
  final ScrollController? externalScrollController;

  const CodeEditorWidget({
    super.key,
    this.externalScrollController,
  });

  @override
  ConsumerState<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends ConsumerState<CodeEditorWidget> {
  CodeController? _controller;
  SyntaxLanguage? _currentLanguage;
  String? _currentFileUri;
  int? _currentFileHash;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  CodeController _getOrCreateController(
      String content, SyntaxLanguage language) {
    final fileUri = ref.read(activeFileProvider)?.uri;
    final fileHash = Object.hash(fileUri, content.hashCode);

    if (_controller != null &&
        _currentLanguage == language &&
        _currentFileHash == fileHash) {
      return _controller!;
    }

    _controller?.dispose();
    _currentLanguage = language;
    _currentFileUri = fileUri;
    _currentFileHash = fileHash;

    final highlightId = LanguageRegistry.getHighlightId(language);
    Mode? mode;
    if (highlightId != null) {
      mode = highlight.getLanguage(highlightId);
    }

    _controller = CodeController(
      text: content,
      language: mode,
    );

    _controller!.addListener(_onTextChanged);

    return _controller!;
  }

  void _onTextChanged() {
    if (_controller == null) return;
    final index = ref.read(activeTabIndexProvider);
    final currentContent = ref.read(activeFileProvider)?.content;
    if (_controller!.text != currentContent) {
      ref.read(openFilesProvider.notifier).updateContent(
            index,
            _controller!.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(activeFileProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final editorTheme = ref.watch(editorThemeProvider);

    if (activeFile == null) {
      return _EmptyState();
    }

    final settings = settingsAsync.valueOrNull ?? const EditorSettings();

    final controller = _getOrCreateController(
      activeFile.content,
      activeFile.language,
    );

    // Use the selected editor theme
    final themeData = editorTheme.themeData;

    return CodeTheme(
      data: CodeThemeData(styles: themeData),
      child: CodeField(
        controller: controller,
        textStyle: GoogleFonts.jetBrainsMono(
          fontSize: settings.fontSize,
        ),
        gutterStyle: GutterStyle(
          showLineNumbers: settings.showLineNumbers,
          showFoldingHandles: true,
          showErrors: true,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: settings.fontSize * 0.85,
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          background: context.colorScheme.surfaceContainerLow,
          width: settings.showLineNumbers ? 64 : 0,
        ),
        wrap: settings.wordWrap,
        minLines: null,
        background: editorTheme.backgroundColor,
      ),
    );
  }
}

/// Empty state shown when no file is open.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.edit_note,
              size: 56,
              color: context.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Code Editor',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a file or create a new one to get started',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickAction(
                icon: Icons.add,
                label: 'New File',
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _QuickAction(
                icon: Icons.folder_open,
                label: 'Open File',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
