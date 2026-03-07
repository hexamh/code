import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/core/utils.dart';
import 'package:myapp/domain/syntax/language_registry.dart';
import 'package:myapp/presentation/providers/editor_providers.dart';

/// Bottom status toolbar showing cursor position, language, and encoding.
class BottomToolbar extends ConsumerWidget {
  final int cursorOffset;
  final ValueChanged<SyntaxLanguage>? onLanguageChanged;

  const BottomToolbar({
    super.key,
    this.cursorOffset = 0,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFile = ref.watch(activeFileProvider);

    if (activeFile == null) return const SizedBox.shrink();

    final pos = AppUtils.getCursorPosition(activeFile.content, cursorOffset);
    final lineCount = AppUtils.countLines(activeFile.content);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Cursor position
          _StatusItem(
            icon: Icons.edit_location_alt_outlined,
            label: 'Ln ${pos.line}, Col ${pos.column}',
          ),
          const SizedBox(width: 16),
          // Total lines
          _StatusItem(
            icon: Icons.format_list_numbered,
            label: '$lineCount lines',
          ),
          const Spacer(),
          // Language selector
          InkWell(
            onTap: () => _showLanguagePicker(context, ref),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                activeFile.language.displayName,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Encoding
          Text(
            activeFile.encoding,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final languages = LanguageRegistry.allLanguages_;
    final activeFile = ref.read(activeFileProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: languages.length,
                itemBuilder: (ctx, index) {
                  final lang = languages[index];
                  final isSelected = lang == activeFile?.language;
                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.code,
                      size: 20,
                    ),
                    title: Text(lang.displayName),
                    subtitle: lang.extensions.isNotEmpty
                        ? Text(
                            lang.extensions.map((e) => '.$e').join(', '),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      final activeIndex = ref.read(activeTabIndexProvider);
                      ref
                          .read(openFilesProvider.notifier)
                          .changeLanguage(activeIndex, lang);
                      onLanguageChanged?.call(lang);
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
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
