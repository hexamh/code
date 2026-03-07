import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/core/extensions.dart';
import 'package:myapp/presentation/providers/search_providers.dart';

/// Search & replace overlay bar.
class SearchBarWidget extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final ValueChanged<int>? onNavigateToMatch;

  const SearchBarWidget({
    super.key,
    this.onClose,
    this.onNavigateToMatch,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  bool _showReplace = false;

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: context.textTheme.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Find...',
                      hintStyle: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: context.colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: context.colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: context.colorScheme.primary),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).setQuery(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Match count
              Text(
                results.isEmpty
                    ? 'No results'
                    : '${query.currentMatchIndex + 1}/${results.length}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: results.isEmpty
                      ? context.colorScheme.error
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              // Navigation buttons
              _IconBtn(
                icon: Icons.keyboard_arrow_up,
                onTap: results.isEmpty
                    ? null
                    : () {
                        ref
                            .read(searchQueryProvider.notifier)
                            .previousMatch(results.length);
                        widget.onNavigateToMatch
                            ?.call(query.currentMatchIndex);
                      },
              ),
              _IconBtn(
                icon: Icons.keyboard_arrow_down,
                onTap: results.isEmpty
                    ? null
                    : () {
                        ref
                            .read(searchQueryProvider.notifier)
                            .nextMatch(results.length);
                        widget.onNavigateToMatch
                            ?.call(query.currentMatchIndex);
                      },
              ),
              // Toggle options
              _ToggleBtn(
                label: '.*',
                isActive: query.isRegex,
                onTap: () =>
                    ref.read(searchQueryProvider.notifier).toggleRegex(),
                tooltip: 'Regex',
              ),
              _ToggleBtn(
                label: 'Aa',
                isActive: query.isCaseSensitive,
                onTap: () => ref
                    .read(searchQueryProvider.notifier)
                    .toggleCaseSensitive(),
                tooltip: 'Case Sensitive',
              ),
              _ToggleBtn(
                label: 'W',
                isActive: query.isWholeWord,
                onTap: () =>
                    ref.read(searchQueryProvider.notifier).toggleWholeWord(),
                tooltip: 'Whole Word',
              ),
              // Toggle replace row
              _IconBtn(
                icon: _showReplace
                    ? Icons.unfold_less
                    : Icons.find_replace,
                onTap: () => setState(() => _showReplace = !_showReplace),
              ),
              // Close
              _IconBtn(
                icon: Icons.close,
                onTap: () {
                  ref.read(searchQueryProvider.notifier).clear();
                  ref.read(searchVisibleProvider.notifier).state = false;
                  widget.onClose?.call();
                },
              ),
            ],
          ),
          // Replace row (expandable)
          if (_showReplace) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _replaceController,
                      style: context.textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Replace...',
                        hintStyle: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: context.colorScheme.primary),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        ref
                            .read(searchQueryProvider.notifier)
                            .setReplacement(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: results.isEmpty ? null : () {},
                  icon: const Icon(Icons.find_replace, size: 16),
                  label: const Text('Replace'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: context.textTheme.labelSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: results.isEmpty ? null : () {},
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('All'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: context.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? context.colorScheme.onSurfaceVariant
              : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _ToggleBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? context.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive
                  ? context.colorScheme.onPrimaryContainer
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
