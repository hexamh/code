import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/data/services/recent_files_service.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';

/// Provider for loading recent files.
final recentFilesListProvider = FutureProvider<List<RecentFile>>((ref) async {
  final service = ref.read(recentFilesServiceProvider);
  return service.getRecentFiles();
});

/// Navigation drawer with recent files and file actions.
class FileDrawer extends ConsumerWidget {
  const FileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFilesAsync = ref.watch(recentFilesListProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primaryContainer,
                    context.colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.edit_note,
                    size: 40,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code Editor',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.add, color: context.colorScheme.primary),
              title: const Text('New File'),
              onTap: () {
                Navigator.pop(context);
                ref.read(openFilesProvider.notifier).createNewFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_open,
                  color: context.colorScheme.primary),
              title: const Text('Open File'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(openFilesProvider.notifier).openFile();
              },
            ),
            const Divider(),

            // Recent files header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Files',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (recentFilesAsync.valueOrNull?.isNotEmpty == true)
                    TextButton(
                      onPressed: () async {
                        final service = ref.read(recentFilesServiceProvider);
                        await service.clearRecentFiles();
                        ref.invalidate(recentFilesListProvider);
                      },
                      child: Text(
                        'Clear All',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Recent files list
            Expanded(
              child: recentFilesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text('Error loading recent files',
                      style: context.textTheme.bodySmall),
                ),
                data: (files) {
                  if (files.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: context.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recent files',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: files.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          file.name,
                          style: context.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatTimestamp(file.timestamp),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: context.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          onPressed: () async {
                            final service =
                                ref.read(recentFilesServiceProvider);
                            await service.removeRecentFile(file.uri);
                            ref.invalidate(recentFilesListProvider);
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Open from path
                          ref.read(fileServiceProvider).openFromPath(file.uri);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }
}
