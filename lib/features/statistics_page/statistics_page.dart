import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/app/app_functions.dart';
import 'package:manga_reader_app/app/app_extensions.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/manga_carousel/manga_carousel.dart';
import 'package:manga_reader_app/core/widgets/section_header/section_header.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const LoadingAnimation(text: "Loading Statistics");
        }

        final List<MangaView> allManga = state.mangaViews;

        if (allManga.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Statistics"),
            ),
            body: const EmptyPage(text: "No manga in your library"),
          );
        }

        final List<MangaView> recentlyRead = allManga
            .where((m) => (m.userManga?.lastReadTimestamp?.millisecondsSinceEpoch ?? 0) > 0)
            .toList()
            .sorted((a, b) => (b.userManga?.lastReadTimestamp?.millisecondsSinceEpoch ?? 0)
            .compareTo(a.userManga?.lastReadTimestamp?.millisecondsSinceEpoch ?? 0))
            .take(5)
            .toList();

        final List<MangaView> mostRead = state.mangaViews
            .where((manga) => manga.userManga != null)
            .where((manga) => manga.userManga!.totalReadingTimeInSeconds! > 0)
            .sorted((a, b) => (b.userManga!.totalReadingTimeInSeconds)!.compareTo(a.userManga!.totalReadingTimeInSeconds!))
            .take(5)
            .toList();

        final totalReadingTime =
        prettyDuration(Duration(seconds: allManga.fold(0, (sum, manga) => sum + (manga.userManga?.totalReadingTimeInSeconds ?? 0))));
        final readMangaCount = allManga.where((m) => (m.userManga?.totalReadingTimeInSeconds ?? 0) > 0).length;
        final favoriteMangaCount = allManga.where((m) => m.userManga?.isFavorite == true).length;
        final totalBookmarks = allManga.fold(0, (sum, manga) => sum + (manga.userManga?.chapterBookmarks?.values.where((isBookmarked) => isBookmarked).length ?? 0));

        final hasStats = recentlyRead.isNotEmpty || mostRead.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Statistics"),
          ),
          body: hasStats
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              shrinkWrap: true,
              children: [
                SectionHeader(title: 'Overall Stats'),
                GridView.count(
                  childAspectRatio: 1 / 1.5,
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ClipRRect(
                      child: _buildStatCard(
                        context,
                        icon: FontAwesomeIcons.bookOpen,
                        label: 'Manga Read',
                        value: '$readMangaCount',
                      ),
                    ),
                    ClipRRect(
                      child: _buildStatCard(
                        context,
                        icon: FontAwesomeIcons.hourglassHalf,
                        label: 'Reading Time',
                        value: totalReadingTime,
                      ),
                    ),
                    ClipRRect(
                      child: _buildStatCard(
                        context,
                        icon: FontAwesomeIcons.heart,
                        label: 'Favorite Mangas',
                        value: '$favoriteMangaCount',
                      ),
                    ),
                    ClipRRect(
                      child: _buildStatCard(
                        context,
                        icon: FontAwesomeIcons.bookmark,
                        label: 'Total Bookmarks',
                        value: '$totalBookmarks',
                      ),
                    ),
                  ],
                ),
                if (recentlyRead.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Recently Read'),
                      MangaCarousel(mangas: recentlyRead),
                    ],
                  ),
                if (mostRead.isNotEmpty)
                  ClipRRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: 'Most Read'),
                        MangaCarousel(mangas: mostRead),
                      ],
                  ),
                ),
              ],
            ),
          )
              : EmptyPage(text: "Start reading to see your stats here"),
        );
      },
    );
  }
}

Widget _buildStatCard(BuildContext context, {required IconData icon, required String label, required String value}) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          FaIcon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}