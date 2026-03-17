import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final String elapsed;
  final String target;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.elapsed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      painter: _RingPainter(
        progress: progress.clamp(0.0, 1.0),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        progressColor: progress >= 1.0
            ? Colors.green
            : theme.colorScheme.primary,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(elapsed,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace')),
            Text('/ $target',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;
    const strokeWidth = 12.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}
