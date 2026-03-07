import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/core/utils.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';
import 'package:myapp/presentation/providers/search_providers.dart';
import 'package:myapp/presentation/providers/settings_providers.dart';
import 'package:myapp/presentation/widgets/about_dialog.dart';
import 'package:myapp/presentation/widgets/bottom_toolbar.dart';
import 'package:myapp/presentation/widgets/code_editor_widget.dart';
import 'package:myapp/presentation/widgets/editor_tab_bar.dart';
import 'package:myapp/presentation/widgets/file_drawer.dart';
import 'package:myapp/presentation/widgets/file_info_dialog.dart';
import 'package:myapp/presentation/widgets/go_to_line_dialog.dart';
import 'package:myapp/presentation/widgets/keyboard_toolbar.dart';
import 'package:myapp/presentation/widgets/minimap_widget.dart';
import 'package:myapp/presentation/widgets/search_bar_widget.dart';
import 'package:myapp/presentation/widgets/snippet_menu.dart';
import 'package:myapp/presentation/widgets/text_stats_panel.dart';
import 'package:myapp/presentation/widgets/text_transforms_menu.dart';

/// Main editor screen with all features integrated.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(activeFileProvider);
    final searchVisible = ref.watch(searchVisibleProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final showMinimap = settings?.showMinimap ?? true;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 80;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'File Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: GestureDetector(
          onTap: () {
            if (activeFile != null) {
              FileInfoDialog.show(context, activeFile);
            }
          },
          child: Text(
            activeFile?.displayName ?? 'Code Editor',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          // Search
          IconButton(
            icon: Icon(
              searchVisible ? Icons.search_off : Icons.search,
              size: 20,
            ),
            tooltip: 'Find & Replace',
            onPressed: () {
              ref.read(searchVisibleProvider.notifier).state = !searchVisible;
            },
          ),
          // Save
          IconButton(
            icon: const Icon(Icons.save_outlined, size: 20),
            tooltip: 'Save',
            onPressed: _saveFile,
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: _handleMenuAction,
            itemBuilder: (_) => [
              _menuItem('new', Icons.add, 'New File'),
              _menuItem('open', Icons.folder_open, 'Open File'),
              _menuItem('save_as', Icons.save_as, 'Save As'),
              const PopupMenuDivider(),
              _menuItem('go_to_line', Icons.format_list_numbered, 'Go to Line'),
              _menuItem('snippets', Icons.code, 'Code Snippets'),
              _menuItem('transforms', Icons.transform, 'Text Transforms'),
              _menuItem('stats', Icons.analytics, 'Text Statistics'),
              const PopupMenuDivider(),
              _menuItem('share', Icons.share, 'Share'),
              _menuItem('file_info', Icons.info_outline, 'File Info'),
              const PopupMenuDivider(),
              _menuItem('settings', Icons.settings, 'Settings'),
              _menuItem('about', Icons.info, 'About'),
            ],
          ),
        ],
      ),
      drawer: const FileDrawer(),
      body: GestureDetector(
        // Pinch-to-zoom font size
        onScaleUpdate: (details) {
          if (details.pointerCount == 2) {
            final currentSize = settings?.fontSize ?? 14;
            final newSize = (currentSize * details.scale).clamp(8.0, 32.0);
            if ((newSize - currentSize).abs() > 0.5) {
              ref.read(settingsProvider.notifier).setFontSize(
                    newSize.roundToDouble(),
                  );
            }
          }
        },
        child: Column(
          children: [
            // Tab bar
            const EditorTabBar(),

            // Search bar
            if (searchVisible)
              SearchBarWidget(
                onClose: () {
                  ref.read(searchVisibleProvider.notifier).state = false;
                },
              ),

            // Editor area
            Expanded(
              child: Row(
                children: [
                  const Expanded(child: CodeEditorWidget()),
                  if (showMinimap && activeFile != null)
                    MinimapWidget(
                      content: activeFile.content,
                      scrollController: _scrollController,
                      viewportHeight: MediaQuery.of(context).size.height * 0.6,
                      totalContentHeight:
                          (activeFile.content.split('\n').length *
                                  (settings?.fontSize ?? 14) *
                                  1.5)
                              .toDouble(),
                    ),
                ],
              ),
            ),

            // Keyboard toolbar
            if (isKeyboardVisible)
              KeyboardToolbar(
                onTab: () => _insertText('\t'),
                onBracketLeft: () => _insertText('{'),
                onBracketRight: () => _insertText('}'),
                onParenLeft: () => _insertText('('),
                onParenRight: () => _insertText(')'),
                onQuote: () => _insertText('"'),
                onSemicolon: () => _insertText(';'),
                onColon: () => _insertText(':'),
                onSlash: () => _insertText('/'),
                onEquals: () => _insertText('='),
                onHideKeyboard: () => FocusScope.of(context).unfocus(),
              ),

            // Bottom toolbar
            const BottomToolbar(),
          ],
        ),
      ),
      floatingActionButton: isKeyboardVisible
          ? null
          : FloatingActionButton.small(
              onPressed: () =>
                  ref.read(openFilesProvider.notifier).createNewFile(),
              tooltip: 'New File',
              child: const Icon(Icons.add),
            ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String title) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _saveFile() async {
    final success =
        await ref.read(openFilesProvider.notifier).saveActiveFile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'File saved' : 'Save cancelled'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _insertText(String text) {
    // Placeholder — to be connected to CodeController
  }

  void _handleMenuAction(String action) {
    final activeFile = ref.read(activeFileProvider);

    switch (action) {
      case 'new':
        ref.read(openFilesProvider.notifier).createNewFile();
        break;
      case 'open':
        ref.read(openFilesProvider.notifier).openFile();
        break;
      case 'save_as':
        if (activeFile != null) {
          ref
              .read(fileServiceProvider)
              .saveFileAs(activeFile.content, activeFile.displayName);
        }
        break;
      case 'go_to_line':
        if (activeFile != null) {
          final lines = AppUtils.countLines(activeFile.content);
          GoToLineDialog.show(
            context,
            currentLine: 1,
            totalLines: lines,
            onGoToLine: (line) {
              // Jump to line — can be connected to scroll controller
            },
          );
        }
        break;
      case 'snippets':
        SnippetMenu.show(context, onInsert: (snippet) {
          // Insert snippet at cursor
          if (activeFile != null) {
            final index = ref.read(activeTabIndexProvider);
            ref.read(openFilesProvider.notifier).updateContent(
                  index,
                  activeFile.content + snippet,
                );
          }
        });
        break;
      case 'transforms':
        if (activeFile != null) {
          TextTransformsMenu.show(
            context,
            selectedText: activeFile.content,
            onApply: (transformed) {
              final index = ref.read(activeTabIndexProvider);
              ref
                  .read(openFilesProvider.notifier)
                  .updateContent(index, transformed);
            },
          );
        }
        break;
      case 'stats':
        if (activeFile != null) {
          TextStatsPanel.show(context, activeFile.content);
        }
        break;
      case 'share':
        if (activeFile != null && activeFile.content.isNotEmpty) {
          // Use clipboard as fallback since share_plus might not be added
          Clipboard.setData(ClipboardData(text: activeFile.content));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content copied to clipboard'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
      case 'file_info':
        if (activeFile != null) {
          FileInfoDialog.show(context, activeFile);
        }
        break;
      case 'settings':
        context.push('/settings');
        break;
      case 'about':
        showAppAboutDialog(context);
        break;
    }
  }
}
