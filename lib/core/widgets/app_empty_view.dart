import 'package:flutter/material.dart';

class AppEmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  const AppEmptyView({
    super.key,
    this.message = 'Nothing here yet',
    this.icon = Icons.inbox_outlined,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
