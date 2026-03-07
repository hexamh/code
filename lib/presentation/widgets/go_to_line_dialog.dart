import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';

/// Dialog for navigating to a specific line number.
class GoToLineDialog extends StatefulWidget {
  final int currentLine;
  final int totalLines;
  final ValueChanged<int> onGoToLine;

  const GoToLineDialog({
    super.key,
    required this.currentLine,
    required this.totalLines,
    required this.onGoToLine,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentLine,
    required int totalLines,
    required ValueChanged<int> onGoToLine,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => GoToLineDialog(
        currentLine: currentLine,
        totalLines: totalLines,
        onGoToLine: onGoToLine,
      ),
    );
  }

  @override
  State<GoToLineDialog> createState() => _GoToLineDialogState();
}

class _GoToLineDialogState extends State<GoToLineDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentLine.toString());
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    final line = int.tryParse(text);
    if (line == null || line < 1 || line > widget.totalLines) {
      setState(() {
        _errorText = 'Enter a number between 1 and ${widget.totalLines}';
      });
      return;
    }
    Navigator.pop(context);
    widget.onGoToLine(line);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.format_list_numbered, color: context.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Go to Line'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current line: ${widget.currentLine} of ${widget.totalLines}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Line number',
              hintText: '1 - ${widget.totalLines}',
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.arrow_forward),
            ),
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Go'),
        ),
      ],
    );
  }
}
