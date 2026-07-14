import 'package:flutter/material.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Animation<double> reveal;
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.reveal,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        return Opacity(
          opacity: reveal.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - reveal.value.clamp(0, 1)) * 16),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
