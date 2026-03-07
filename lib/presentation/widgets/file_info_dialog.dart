import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/core/utils.dart';
import 'package:myapp/data/models/editor_file.dart';

/// Dialog showing detailed file information.
class FileInfoDialog extends StatelessWidget {
  final EditorFile file;

  const FileInfoDialog({super.key, required this.file});

  static void show(BuildContext context, EditorFile file) {
    showDialog(
      context: context,
      builder: (_) => FileInfoDialog(file: file),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lineCount = AppUtils.countLines(file.content);
    final wordCount = file.content.trim().isEmpty
        ? 0
        : file.content.trim().split(RegExp(r'\s+')).length;
    final sizeStr = AppUtils.formatFileSize(file.content.length);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: context.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('File Info'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InfoRow(label: 'Name', value: file.displayName, icon: Icons.description),
          _InfoRow(label: 'Language', value: file.language.displayName, icon: Icons.code),
          _InfoRow(label: 'Encoding', value: file.encoding, icon: Icons.text_format),
          _InfoRow(label: 'Lines', value: '$lineCount', icon: Icons.format_list_numbered),
          _InfoRow(label: 'Words', value: '$wordCount', icon: Icons.text_fields),
          _InfoRow(label: 'Size', value: sizeStr, icon: Icons.data_usage),
          _InfoRow(
            label: 'Status',
            value: file.isDirty ? 'Modified' : 'Saved',
            icon: file.isDirty ? Icons.edit : Icons.check_circle,
            valueColor: file.isDirty
                ? context.colorScheme.error
                : Colors.green,
          ),
          if (file.uri != null)
            _InfoRow(
              label: 'Path',
              value: file.uri!,
              icon: Icons.folder_outlined,
              maxLines: 3,
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final int maxLines;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
