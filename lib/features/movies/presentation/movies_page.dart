import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import '../../profile/presentation/profile_avatar_action.dart';
import '../domain/movie_list_type.dart';
import 'movie_category_grid.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: MovieListType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TMDB Movie Explorer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Favorites',
              onPressed: () => Get.toNamed(AppRoutes.favorites),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Get.toNamed(AppRoutes.search),
            ),
            const ProfileAvatarAction(),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: scheme.onSurface,
            indicatorWeight: 2,
            labelColor: scheme.onSurface,
            unselectedLabelColor: scheme.outline,
            tabs: [
              for (final type in MovieListType.values) Tab(text: type.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final type in MovieListType.values)
              MovieCategoryGrid(type: type),
          ],
        ),
      ),
    );
  }
}
