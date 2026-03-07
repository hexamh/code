import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/core/text_transforms.dart';

/// Bottom sheet menu for applying text transformations.
class TextTransformsMenu extends StatelessWidget {
  final String selectedText;
  final ValueChanged<String> onApply;

  const TextTransformsMenu({
    super.key,
    required this.selectedText,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required String selectedText,
    required ValueChanged<String> onApply,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TextTransformsMenu(
        selectedText: selectedText,
        onApply: onApply,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transforms = [
      _TransformItem('UPPERCASE', Icons.keyboard_capslock,
          () => TextTransforms.toUpperCase(selectedText)),
      _TransformItem('lowercase', Icons.text_fields,
          () => TextTransforms.toLowerCase(selectedText)),
      _TransformItem('Title Case', Icons.title,
          () => TextTransforms.toTitleCase(selectedText)),
      _TransformItem('snake_case', Icons.horizontal_rule,
          () => TextTransforms.toSnakeCase(selectedText)),
      _TransformItem('camelCase', Icons.merge_type,
          () => TextTransforms.toCamelCase(selectedText)),
      _TransformItem('Sort Lines (A→Z)', Icons.sort_by_alpha,
          () => TextTransforms.sortLines(selectedText)),
      _TransformItem('Sort Lines (Z→A)', Icons.sort_by_alpha,
          () => TextTransforms.sortLines(selectedText, descending: true)),
      _TransformItem('Remove Duplicate Lines', Icons.filter_list,
          () => TextTransforms.removeDuplicateLines(selectedText)),
      _TransformItem('Trim Trailing Whitespace', Icons.space_bar,
          () => TextTransforms.trimTrailingWhitespace(selectedText)),
      _TransformItem('Add Line Numbers', Icons.format_list_numbered,
          () => TextTransforms.addLineNumbers(selectedText)),
      _TransformItem('Join Lines', Icons.compress,
          () => TextTransforms.joinLines(selectedText)),
      _TransformItem('Reverse Lines', Icons.swap_vert,
          () => TextTransforms.reverseLines(selectedText)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
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
              Icon(Icons.transform, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Text Transforms',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: transforms.length,
            itemBuilder: (context, index) {
              final t = transforms[index];
              return ListTile(
                leading: Icon(t.icon, size: 20),
                title: Text(t.name),
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  onApply(t.apply());
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TransformItem {
  final String name;
  final IconData icon;
  final String Function() apply;

  const _TransformItem(this.name, this.icon, this.apply);
}
