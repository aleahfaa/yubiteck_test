import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MonoNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const MonoNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder(context);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, _) => _placeholder(context),
      errorWidget: (context, _, _) => _placeholder(context, isError: true),
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _placeholder(BuildContext context, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.grey900 : AppColors.grey100,
      alignment: Alignment.center,
      child: Icon(
        isError ? Icons.broken_image_outlined : Icons.movie_outlined,
        color: isDark ? AppColors.grey700 : AppColors.grey300,
      ),
    );
  }
}
