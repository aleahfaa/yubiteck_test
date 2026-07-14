import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String label;
  const GenreChip({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: scheme.outline)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
