import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_button_styles.dart';
import 'ratings_controller.dart';
import 'animated_rating_dial.dart';

Future<void> showRatingInputSheet(
  BuildContext context, {
  required int movieId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
    ),
    builder: (_) => _RatingInputSheet(movieId: movieId),
  );
}

class _RatingInputSheet extends StatefulWidget {
  final int movieId;
  const _RatingInputSheet({required this.movieId});
  @override
  State<_RatingInputSheet> createState() => _RatingInputSheetState();
}

class _RatingInputSheetState extends State<_RatingInputSheet> {
  late final RatingsController _controller;
  late double _draftValue;
  @override
  void initState() {
    super.initState();
    _controller = Get.find<RatingsController>();
    _draftValue = _controller.ratingFor(widget.movieId) ?? 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasExistingRating = _controller.ratingFor(widget.movieId) != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rate this movie', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            AnimatedRatingDial(value: _draftValue, size: 72),
            Slider(
              value: _draftValue,
              min: 0.5,
              max: 10,
              divisions: 19,
              label: _draftValue.toStringAsFixed(1),
              onChanged: (v) => setState(() => _draftValue = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (hasExistingRating)
                  Expanded(
                    child: OutlinedButton(
                      style: AppButtonStyles.outlined(context),
                      onPressed: () {
                        _controller.deleteRating(widget.movieId);
                        Navigator.of(context).pop();
                      },
                      child: const Text('REMOVE'),
                    ),
                  ),
                if (hasExistingRating) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: AppButtonStyles.filled(context),
                    onPressed: () {
                      _controller.rate(widget.movieId, _draftValue);
                      Navigator.of(context).pop();
                    },
                    child: const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
