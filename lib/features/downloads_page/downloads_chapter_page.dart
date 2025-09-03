import 'package:flutter/material.dart';
import 'package:manga_reader_app/core/cubit/download_manager/download_manager_cubit.dart';
import 'package:manga_reader_app/core/cubit/download_manager/download_manager_state.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';

class DownloadedMangaDetailsPage extends StatelessWidget {
  final Manga manga;

  const DownloadedMangaDetailsPage({super.key, required this.manga});

  Future<void> _showDeleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('Are you sure you want to delete this chapter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onConfirm,
              child: const Text('Delete'),
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
        title: Text(manga.title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingAnimation(text: "Checking Files");
          }

          if (state.errorMessage != null) {
            return const ErrorPage();
          }

          if (!state.isLoading) {
            final List<DownloadedChapterView> chapters = state.downloadedChapterDetailsFromManga(manga.link);
            chapters.sort((a, b) => b.chapter.title.compareTo(a.chapter.title));
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: chapters.isNotEmpty
                                    ? () =>context.read<DownloadManagerCubit>().deleteAllChaptersForManga(manga.link)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete All'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: chapters.any((chapter) =>
                                chapter.isRead)
                                    ? () => context.read<DownloadManagerCubit>().deleteReadChaptersForManga(manga.link)
                                    : null,
                                child: const Text('Delete Read'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: chapters.isEmpty ? const EmptyPage(text: 'No downloaded chapters for this manga.') : ListView(
                    children: [
                      const Divider(),
                      ...chapters.map((chapter) {
                        return Column(
                          children: [
                            ListTile(
                              leading: chapter.isRead ? Icon(
                                  Icons.visibility
                              ) : null,
                              title: Text(chapter.chapter.title),
                              subtitle: Text(
                                '${chapter.sizeInMB.toStringAsFixed(2)} MB',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                        context: context,
                                        title: 'Delete ${chapter.chapter.title}',
                                        onConfirm: () {
                                          Navigator.of(context).pop();
                                          context.read<DownloadManagerCubit>().deleteSingleDownloadedChapter(
                                            manga.link,
                                            chapter.chapter.id!,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      }
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
