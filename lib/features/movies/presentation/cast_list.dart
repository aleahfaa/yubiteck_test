import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/mono_network_image.dart';
import '../domain/cast_member.dart';

class CastList extends StatelessWidget {
  final List<CastMember> cast;
  const CastList({super.key, required this.cast});
  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = cast[index];
          return SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: MonoNetworkImage(
                      url: ApiConstants.imageUrl(
                        member.profilePath,
                        size: ApiConstants.profileSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
                ),
                Text(
                  member.character,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
