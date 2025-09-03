import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/cubit/chapter_download/chapter_download_cubit.dart';
import 'package:manga_reader_app/core/cubit/chapter_download/chapter_download_state.dart';
import 'package:manga_reader_app/core/cubit/download_manager/download_manager_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/enums/chapter_download_status.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/features/reading_page/reading_page.dart';

import 'manga_chapter_selection_cubit.dart';

class MangaChapterTile extends StatelessWidget {
  const MangaChapterTile({
    super.key,
    required this.mangaTitle,
    required this.chapter,
    required this.isSelected,
    required this.isSelectionMode,
    required this.chapters,
  });

  final String mangaTitle;
  final List<Chapter> chapters;
  final Chapter chapter;
  final bool isSelected;
  final bool isSelectionMode;


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
        builder: (context, state) {
          final MangaView manga = state.mangaViews.firstWhere(
                (search) => search.title == mangaTitle,
            orElse: () => throw Exception("Manga not found"),
          );
          final Chapter displayedChapter = manga.chapters.firstWhere(
                (search) => search.id == chapter.id,
            orElse: () => throw Exception("Chapter not found"),
          );
          final bool isBookmarked = context.read<MangaLibraryCubit>().isChapterBookmarked(manga.link, displayedChapter.id!);
          final isDownloaded = manga.downloadedImagePathsByChapter.containsKey(displayedChapter.id);

          void handleReadingPageClose(int elapsedTimeInSeconds) {
            context.read<MangaLibraryCubit>().updateTotalReadingTime(
              mangaLink: manga.link,
              seconds: elapsedTimeInSeconds,
            );
          }
          return GestureDetector(
              onLongPress: () {
                int id = chapter.id ?? -1;
                if(isSelectionMode) {
                  if(isSelected) {
                    context.read<SelectionCubit>().toggleSelection(id);
                  }
                  else {
                    context.read<SelectionCubit>().toggleRangeSelection(id, chapters);
                  }
                }
                else {
                  context.read<SelectionCubit>().toggleSelection(id);
                }
              },
              onTap: () {
                int id = chapter.id ?? -1;
                if (isSelectionMode) {
                  context.read<SelectionCubit>().toggleSelection(id);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ReadingPage(
                        mangaView: manga,
                        chapter: chapter,
                        onClose: (elapsedSeconds) {
                          handleReadingPageClose(elapsedSeconds);
                        },
                      ),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: isSelected
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
                  child: ListTile(
                      leading: isSelectionMode
                          ? Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          context.read<SelectionCubit>().toggleSelection(chapter.id ?? -1);
                        },
                      )
                          : null,
                      title: Row(
                        children: [
                          Visibility(
                            visible: isBookmarked,
                            child: const Icon(
                              Icons.bookmark,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            chapter.title,
                            style: manga.getIsRead(displayedChapter.id ?? -1) ?
                            TextStyle(color: Colors.grey.withOpacity(0.5)) :
                            const TextStyle(),
                          )
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(chapter.released ?? "", style: manga.getIsRead(displayedChapter.id  ?? -1) ? TextStyle(color: Colors.grey.withOpacity(0.5)) : TextStyle(),),
                          Visibility(
                            visible: manga.getLastPageRead(chapter.id  ?? -1) > 0,
                            child: Text(
                              "${manga.getLastPageRead(chapter.id  ?? -1) + 1}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    trailing: isSelectionMode
                        ? null
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BlocBuilder<ChapterDownloadCubit, ChapterDownloadState>(
                          builder: (context, downloadState) {
                            if (downloadState.status == ChapterDownloadStatus.inProgress && downloadState.chapterId == chapter.id) {
                              return Stack(
                                alignment: AlignmentGeometry.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      value:  downloadState.progress,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      context.read<ChapterDownloadCubit>().cancelDownload(chapter.id  ?? -1);
                                    },
                                    icon: const FaIcon(FontAwesomeIcons.ban, size: 16,),
                                  ),
                                ],
                              );
                            }
                            else if (context.read<ChapterDownloadCubit>().isInQueue(chapter.id!)) {
                              return Stack(
                                alignment: AlignmentGeometry.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: 24,
                                    height: 24,
                                    child: const CircularProgressIndicator(
                                      key: Key('loading'),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      context.read<ChapterDownloadCubit>().cancelDownload(chapter.id  ?? -1);
                                    },
                                    icon: const FaIcon(FontAwesomeIcons.ban, size: 16,),
                                  ),
                                ],
                              );
                            }
                            if (isDownloaded) {
                              return IconButton(
                                alignment: AlignmentDirectional.center,
                                onPressed: () {
                                  manga.downloadedImagePathsByChapter.remove(chapter.id);
                                  context.read<DownloadManagerCubit>().deleteSingleDownloadedChapter(
                                    manga.link, chapter.id  ?? -1,
                                  );
                                },
                                icon: const FaIcon(FontAwesomeIcons.solidCircleXmark),
                              );
                            }
                            return IconButton(
                              alignment: AlignmentDirectional.center,
                              onPressed: () {
                                context.read<ChapterDownloadCubit>().downloadChapter(
                                  mangaLink: manga.link, chapterId: chapter.id  ?? -1,
                                );
                              },
                              icon: const FaIcon(FontAwesomeIcons.solidCircleDown),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ),
          );
        },
    );
  }
}