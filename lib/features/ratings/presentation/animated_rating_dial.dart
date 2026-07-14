import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedRatingDial extends StatelessWidget {
  final double? value;
  final double size;
  final VoidCallback? onTap;
  const AnimatedRatingDial({
    super.key,
    required this.value,
    this.size = 56,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = (value ?? 0).clamp(0, 10).toDouble();
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RatingDialPainter(
                progress: animatedValue / 10,
                trackColor: scheme.outline,
                progressColor: scheme.onSurface,
              ),
              child: Center(
                child: Text(
                  value == null ? '–' : animatedValue.toStringAsFixed(1),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: size * 0.28),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RatingDialPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  const _RatingDialPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 6) / 2;
    final strokeWidth = size.shortestSide * 0.07;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RatingDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
