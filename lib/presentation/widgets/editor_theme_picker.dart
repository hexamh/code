import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/domain/editor_themes.dart';

/// Bottom sheet for selecting a syntax editor theme.
class EditorThemePicker extends StatelessWidget {
  final EditorTheme currentTheme;
  final ValueChanged<EditorTheme> onThemeSelected;

  const EditorThemePicker({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  static void show(
    BuildContext context, {
    required EditorTheme currentTheme,
    required ValueChanged<EditorTheme> onThemeSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, scrollController) => EditorThemePicker(
          currentTheme: currentTheme,
          onThemeSelected: onThemeSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themes = EditorTheme.allSorted;

    return Column(
      children: [
        // Handle
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.palette, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Editor Theme',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: themes.length,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isSelected = theme == currentTheme;

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: theme.isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(theme.displayName),
                subtitle: Text(
                  theme.isDark ? 'Dark theme' : 'Light theme',
                  style: context.textTheme.bodySmall,
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: context.colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onThemeSelected(theme);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
