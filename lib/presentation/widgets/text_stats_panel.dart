import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/core/utils.dart';

/// Panel showing text statistics: lines, words, characters, size.
class TextStatsPanel extends StatelessWidget {
  final String content;

  const TextStatsPanel({super.key, required this.content});

  static void show(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TextStatsPanel(content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = AppUtils.countLines(content);
    final words = content.trim().isEmpty
        ? 0
        : content.trim().split(RegExp(r'\s+')).length;
    final chars = content.length;
    final charsNoSpaces = content.replaceAll(RegExp(r'\s'), '').length;
    final sizeBytes = content.length; // UTF-8 approx
    final paragraphs = content.split(RegExp(r'\n\s*\n')).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Text Statistics',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Stats grid
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Lines', value: '$lines', icon: Icons.format_list_numbered)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Words', value: '$words', icon: Icons.text_fields)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Characters', value: '$chars', icon: Icons.abc)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'No Spaces', value: '$charsNoSpaces', icon: Icons.space_bar)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Paragraphs', value: '$paragraphs', icon: Icons.segment)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Size', value: AppUtils.formatFileSize(sizeBytes), icon: Icons.data_usage)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
