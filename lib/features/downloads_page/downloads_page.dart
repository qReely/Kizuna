import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/cubit/download_manager/download_manager_cubit.dart';
import 'package:manga_reader_app/core/cubit/download_manager/download_manager_state.dart';
import 'package:manga_reader_app/core/enums/download_manga_sort_option.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'downloads_chapter_page.dart';

class DownloadedChaptersPage extends StatelessWidget {
  const DownloadedChaptersPage({super.key});

  Future<void> _showDeleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required VoidCallback onDeleteAll,
    required VoidCallback onDeleteRead,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Text(
            'Are you sure you want to delete all chapters or just the read ones?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteRead();
              },
              child: const Text('Delete Read'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteAll();
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: FaIcon(FontAwesomeIcons.upDown),
            iconSize: 20,
            onSelected: (SortOption result) {
              context.read<DownloadManagerCubit>().sort(result, isAscending: !context.read<DownloadManagerCubit>().state.isAscending);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.title,
                child: Text('By Title'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.size,
                child: Text('By Size'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.chapterCount,
                child: Text('By Chapter Count'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingAnimation(text: "Checking Files");
          }

          if (state.errorMessage != null) {
            if(kDebugMode) {
              debugPrint(state.errorMessage);
            }
            return const ErrorPage();
          }

          final downloadedMangas = context.read<DownloadManagerCubit>().state.downloadedMangaDetails;

          if (downloadedMangas.isEmpty) {
            return const EmptyPage(text: 'No downloaded mangas found');
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Downloaded Space:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${context.read<DownloadManagerCubit>().state.totalDownloadedSize.toStringAsFixed(2)} MB',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: downloadedMangas.isNotEmpty
                                ? () => _showDeleteConfirmationDialog(
                              context: context,
                              title: 'Delete All Chapters',
                              onDeleteAll: () => context.read<DownloadManagerCubit>().deleteAllChapters(),
                              onDeleteRead: () => context.read<DownloadManagerCubit>().deleteReadChapters(),
                            )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delete Chapters'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Downloaded Mangas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: downloadedMangas.length,
                  itemBuilder: (context, index) {
                    Manga manga = state.downloadedMangaDetails[index].manga;
                    List<DownloadedChapterView> chapters = context.read<DownloadManagerCubit>().state.downloadedChapterDetailsFromManga(manga.link);
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: manga.image!,
                        width: 40,
                        fit: BoxFit.fitHeight,
                        errorWidget: (context, url, error) => const Icon(Icons.menu_book),
                      ),
                      title: Text(manga.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
                      subtitle: Text('${chapters.length} chapter${manga.chapters.length > 1 ? 's' : ''} - ${state.downloadedMangaDetails[index].sizeInMB.toStringAsFixed(2)} MB'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                            context: context,
                            title: 'Delete ${manga.title}',
                            onDeleteAll: () => context.read<DownloadManagerCubit>().deleteAllChaptersForManga(manga.link),
                            onDeleteRead: () => context.read<DownloadManagerCubit>().deleteReadChaptersForManga(manga.link),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadedMangaDetailsPage(manga: manga),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}