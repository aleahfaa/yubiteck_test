import 'package:flutter/material.dart';

abstract final class AppButtonStyles {
  static ButtonStyle outlined(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.styleFrom(
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: scheme.outline),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  static ButtonStyle filled(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      backgroundColor: scheme.onSurface,
      foregroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }
}
