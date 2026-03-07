import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';

/// A floating keyboard shortcuts toolbar for common editing actions.
class KeyboardToolbar extends StatelessWidget {
  final VoidCallback? onTab;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onBracketLeft;
  final VoidCallback? onBracketRight;
  final VoidCallback? onParenLeft;
  final VoidCallback? onParenRight;
  final VoidCallback? onQuote;
  final VoidCallback? onSemicolon;
  final VoidCallback? onColon;
  final VoidCallback? onSlash;
  final VoidCallback? onEquals;
  final VoidCallback? onHideKeyboard;

  const KeyboardToolbar({
    super.key,
    this.onTab,
    this.onUndo,
    this.onRedo,
    this.onBracketLeft,
    this.onBracketRight,
    this.onParenLeft,
    this.onParenRight,
    this.onQuote,
    this.onSemicolon,
    this.onColon,
    this.onSlash,
    this.onEquals,
    this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        children: [
          _ToolbarKey(label: 'Tab', onTap: onTab),
          _ToolbarDivider(),
          _ToolbarKey(icon: Icons.undo, onTap: onUndo),
          _ToolbarKey(icon: Icons.redo, onTap: onRedo),
          _ToolbarDivider(),
          _ToolbarKey(label: '{', onTap: onBracketLeft),
          _ToolbarKey(label: '}', onTap: onBracketRight),
          _ToolbarKey(label: '(', onTap: onParenLeft),
          _ToolbarKey(label: ')', onTap: onParenRight),
          _ToolbarKey(label: '[', onTap: () {}),
          _ToolbarKey(label: ']', onTap: () {}),
          _ToolbarDivider(),
          _ToolbarKey(label: '"', onTap: onQuote),
          _ToolbarKey(label: "'", onTap: () {}),
          _ToolbarKey(label: ';', onTap: onSemicolon),
          _ToolbarKey(label: ':', onTap: onColon),
          _ToolbarKey(label: '/', onTap: onSlash),
          _ToolbarKey(label: '=', onTap: onEquals),
          _ToolbarKey(label: '<', onTap: () {}),
          _ToolbarKey(label: '>', onTap: () {}),
          _ToolbarKey(label: '&', onTap: () {}),
          _ToolbarKey(label: '|', onTap: () {}),
          _ToolbarKey(label: '!', onTap: () {}),
          _ToolbarKey(label: '#', onTap: () {}),
          _ToolbarKey(label: '_', onTap: () {}),
          _ToolbarDivider(),
          _ToolbarKey(
            icon: Icons.keyboard_hide,
            onTap: onHideKeyboard,
          ),
        ],
      ),
    );
  }
}

class _ToolbarKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _ToolbarKey({this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minWidth: 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(
                    icon,
                    size: 18,
                    color: context.colorScheme.onSurface,
                  )
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        width: 1,
        color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}
