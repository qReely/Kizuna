import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/chapter_download/chapter_download_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/features/manga_chapters/manga_chapter_selection_cubit.dart';
import 'package:collection/collection.dart';

class BulkActionSheet extends StatelessWidget {
  final String mangaLink;
  const BulkActionSheet({
    super.key,
    required this.mangaLink,
  });


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
      builder: (context, libraryState) {
        final MangaView? mangaView = libraryState.mangaViews.firstWhereOrNull((view) => view.link == mangaLink);
        final contWidth = ((MediaQuery.of(context).size.width - (5 * 8)) / 4.5).floorToDouble();
        if (mangaView == null) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<SelectionCubit, Set<int>>(
          builder: (context, selectedChapters) {
            final hasUnread = selectedChapters.any((id) => !mangaView.getIsRead(id));
            final hasRead = selectedChapters.any((id) => mangaView.getIsRead(id));
            final isSingleSelection = selectedChapters.length == 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: contWidth,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: const Icon(Icons.bookmark_added_rounded, size: 24),
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(25),
                                right: Radius.circular(25),
                              ),
                              child: InkWell(
                                splashColor: Colors.white30,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(25),
                                  right: Radius.circular(25),
                                ),
                                onTap: () {
                                  bool allBookmarked = true;
                                  for(int chapterId in selectedChapters) {
                                    if(!context.read<MangaLibraryCubit>().isChapterBookmarked(mangaView.manga.link, chapterId)) {
                                      allBookmarked = false;
                                      break;
                                    }
                                  }
                                  context.read<MangaLibraryCubit>().toggleChapterBookmark(mangaView.manga.link, selectedChapters.toList(), isBookmarked: !allBookmarked);
                                  context.read<SelectionCubit>().clearSelection();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: hasUnread,
                      child: const SizedBox(width: 8),
                    ),
                    Visibility(
                      visible: hasUnread,
                      child: Container(
                        width: contWidth,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(25),
                            right: Radius.circular(25),
                          ),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: const Icon(Icons.done_all_outlined, size: 24),
                            ),
                            SizedBox.expand(
                              child: Material(
                                type: MaterialType.transparency,
                                color: Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(25),
                                  right: Radius.circular(25),
                                ),
                                child: InkWell(
                                  splashColor: Colors.white30,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(25),
                                    right: Radius.circular(25),
                                  ),
                                  onTap: () {
                                    context.read<MangaLibraryCubit>().updateBulkChapterReadStatus(
                                      mangaView.manga.link,
                                      selectedChapters,
                                      isRead: true,
                                    );
                                    context.read<SelectionCubit>().clearSelection();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: hasRead,
                      child: const SizedBox(width: 8),
                    ),
                    Visibility(
                      visible: hasRead,
                      child: Container(
                        width: contWidth,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(25),
                            right: Radius.circular(25),
                          ),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove_done_outlined, size: 24),
                            ),
                            SizedBox.expand(
                              child: Material(
                                type: MaterialType.transparency,
                                color: Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(25),
                                  right: Radius.circular(25),
                                ),
                                child: InkWell(
                                  splashColor: Colors.white30,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(25),
                                    right: Radius.circular(25),
                                  ),
                                  onTap: () {
                                    context.read<MangaLibraryCubit>().updateBulkChapterReadStatus(
                                      mangaView.manga.link,
                                      selectedChapters,
                                      isRead: false,
                                    );
                                    context.read<SelectionCubit>().clearSelection();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isSingleSelection,
                      child: const SizedBox(width: 8),
                    ),
                    Visibility(
                      visible: isSingleSelection,
                      child: Container(
                        width: contWidth,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(25),
                            right: Radius.circular(25),
                          ),
                        ),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              child: const Icon(Icons.keyboard_double_arrow_down_rounded, size: 24),
                            ),
                            SizedBox.expand(
                              child: Material(
                                type: MaterialType.transparency,
                                color: Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(25),
                                  right: Radius.circular(25),
                                ),
                                child: InkWell(
                                  splashColor: Colors.white30,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(25),
                                    right: Radius.circular(25),
                                  ),
                                  onTap: () {
                                    context.read<MangaLibraryCubit>().markAllBelowAsRead(
                                      mangaView.manga.link,
                                      selectedChapters.first,
                                    );
                                    context.read<SelectionCubit>().clearSelection();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: contWidth,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: const Icon(Icons.download_outlined, size: 24),
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(25),
                                right: Radius.circular(25),
                              ),
                              child: InkWell(
                                splashColor: Colors.white30,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(25),
                                  right: Radius.circular(25),
                                ),
                                onTap: () {
                                  List<int> toDownload = [];
                                  selectedChapters.toList().forEach((chapterId) {
                                    if(!mangaView.downloadedImagePathsByChapter.containsKey(chapterId)) {
                                     toDownload.add(chapterId);
                                    }
                                  });
                                  for(int chapter in toDownload.reversed.toList()) {
                                    context.read<ChapterDownloadCubit>().downloadChapter(mangaLink: mangaView.manga.link,  chapterId: chapter);
                                  }
                                  context.read<SelectionCubit>().clearSelection();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
