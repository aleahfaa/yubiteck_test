import 'package:flutter/material.dart';

class RatingBadge extends StatelessWidget {
  final double voteAverage;
  const RatingBadge({super.key, required this.voteAverage});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.88),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 11, color: scheme.onSurface),
          const SizedBox(width: 3),
          Text(
            voteAverage.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
