import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myapp/core/extensions.dart';

/// Minimap scroll overview widget that shows a condensed view of the entire file.
class MinimapWidget extends StatelessWidget {
  final String content;
  final ScrollController scrollController;
  final double viewportHeight;
  final double totalContentHeight;

  const MinimapWidget({
    super.key,
    required this.content,
    required this.scrollController,
    required this.viewportHeight,
    required this.totalContentHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh
            .withValues(alpha: 0.8),
        border: Border(
          left: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minimapHeight = constraints.maxHeight;
          final lines = content.split('\n');
          final lineHeight = math.min(2.0, minimapHeight / math.max(lines.length, 1));

          return GestureDetector(
            onTapDown: (details) => _scrollToPosition(details.localPosition.dy, minimapHeight),
            onVerticalDragUpdate: (details) => _scrollToPosition(details.localPosition.dy, minimapHeight),
            child: CustomPaint(
              size: Size(60, minimapHeight),
              painter: _MinimapPainter(
                lines: lines,
                lineHeight: lineHeight,
                scrollOffset: scrollController.hasClients ? scrollController.offset : 0,
                viewportHeight: viewportHeight,
                totalContentHeight: totalContentHeight,
                minimapHeight: minimapHeight,
                textColor: context.colorScheme.onSurface.withValues(alpha: 0.4),
                viewportColor: context.colorScheme.primary.withValues(alpha: 0.15),
                viewportBorderColor: context.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToPosition(double tapY, double minimapHeight) {
    if (!scrollController.hasClients || totalContentHeight <= 0) return;
    final fraction = (tapY / minimapHeight).clamp(0.0, 1.0);
    final maxScroll = scrollController.position.maxScrollExtent;
    scrollController.jumpTo(fraction * maxScroll);
  }
}

class _MinimapPainter extends CustomPainter {
  final List<String> lines;
  final double lineHeight;
  final double scrollOffset;
  final double viewportHeight;
  final double totalContentHeight;
  final double minimapHeight;
  final Color textColor;
  final Color viewportColor;
  final Color viewportBorderColor;

  _MinimapPainter({
    required this.lines,
    required this.lineHeight,
    required this.scrollOffset,
    required this.viewportHeight,
    required this.totalContentHeight,
    required this.minimapHeight,
    required this.textColor,
    required this.viewportColor,
    required this.viewportBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPaint = Paint()
      ..color = textColor
      ..strokeWidth = 1.0;

    // Draw condensed text lines
    for (int i = 0; i < lines.length; i++) {
      final y = i * lineHeight;
      if (y > size.height) break;

      final line = lines[i];
      if (line.trim().isEmpty) continue;

      // Calculate indentation
      final indent = line.length - line.trimLeft().length;
      final contentLength = math.min(line.trimLeft().length, 40);

      // Draw a thin line representing the text
      final x1 = (indent * 1.5).clamp(0.0, 20.0);
      final x2 = (x1 + contentLength * 0.8).clamp(x1, size.width - 4);

      canvas.drawLine(
        Offset(x1 + 2, y),
        Offset(x2, y),
        textPaint,
      );
    }

    // Draw viewport indicator
    if (totalContentHeight > 0) {
      final maxScroll = totalContentHeight - viewportHeight;
      final scrollFraction = maxScroll > 0 ? (scrollOffset / maxScroll).clamp(0.0, 1.0) : 0.0;

      final vpHeightFraction = (viewportHeight / totalContentHeight).clamp(0.0, 1.0);
      final vpHeight = vpHeightFraction * size.height;
      final vpY = scrollFraction * (size.height - vpHeight);

      // Viewport background
      canvas.drawRect(
        Rect.fromLTWH(0, vpY, size.width, vpHeight),
        Paint()..color = viewportColor,
      );

      // Viewport border
      canvas.drawRect(
        Rect.fromLTWH(0, vpY, size.width, vpHeight),
        Paint()
          ..color = viewportBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) {
    return old.scrollOffset != scrollOffset ||
        old.lines.length != lines.length ||
        old.viewportHeight != viewportHeight;
  }
}
