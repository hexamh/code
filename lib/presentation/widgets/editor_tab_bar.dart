import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';
import 'package:myapp/core/extensions.dart';

/// Horizontal scrollable tab bar for open files.
class EditorTabBar extends ConsumerWidget {
  const EditorTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(openFilesProvider);
    final activeIndex = ref.watch(activeTabIndexProvider);

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        padding: const EdgeInsets.only(left: 4),
        itemBuilder: (context, index) {
          final file = files[index];
          final isActive = index == activeIndex;

          return GestureDetector(
            onTap: () {
              ref.read(activeTabIndexProvider.notifier).state = index;
            },
            onLongPress: () => _showTabContextMenu(context, ref, index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(top: 4, right: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? context.colorScheme.surface
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: isActive
                    ? Border(
                        top: BorderSide(
                          color: context.colorScheme.primary,
                          width: 2,
                        ),
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language icon
                  Icon(
                    _getFileIcon(file.displayName),
                    size: 16,
                    color: isActive
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  // File name
                  Text(
                    file.displayName.truncate(20),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? context.colorScheme.onSurface
                          : context.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  // Dirty indicator
                  if (file.isDirty) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  // Close button
                  InkWell(
                    onTap: () {
                      ref.read(openFilesProvider.notifier).closeFile(index);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: context.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTabContextMenu(BuildContext context, WidgetRef ref, int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Close'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(openFilesProvider.notifier).closeFile(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_fullscreen),
              title: const Text('Close Others'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(openFilesProvider.notifier).closeOthers(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Close All'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(openFilesProvider.notifier).closeAll();
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String name) {
    final ext = name.fileExtension;
    return switch (ext) {
      'dart' => Icons.flutter_dash,
      'py' => Icons.code,
      'js' || 'ts' || 'jsx' || 'tsx' => Icons.javascript,
      'html' || 'htm' => Icons.html,
      'css' || 'scss' => Icons.css,
      'json' => Icons.data_object,
      'xml' || 'svg' => Icons.code,
      'md' || 'markdown' => Icons.article,
      'yaml' || 'yml' => Icons.settings,
      'sql' => Icons.storage,
      'sh' || 'bash' => Icons.terminal,
      _ => Icons.description,
    };
  }
}
