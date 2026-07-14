import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/mono_network_image.dart';

class AnimatedAvatarRing extends StatelessWidget {
  final String? avatarUrl;
  final double progress;
  final double size;
  const AnimatedAvatarRing({
    super.key,
    required this.avatarUrl,
    required this.progress,
    this.size = 120,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: scheme.onSurface),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Hero(
            tag: 'profile-avatar',
            child: ClipOval(
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: scheme.outline,
                      ),
                    )
                  : MonoNetworkImage(
                      url: avatarUrl!.startsWith('http')
                          ? avatarUrl!
                          : ApiConstants.imageUrl(avatarUrl),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
