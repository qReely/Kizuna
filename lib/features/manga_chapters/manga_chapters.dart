import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/enums/chapter_filter_enum.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/features/manga_chapters/manga_chapter_cubit.dart';
import 'package:manga_reader_app/features/manga_chapters/manga_chapters_list.dart';

import 'manga_chapter_bottom_sheet.dart';
import 'manga_chapter_selection_cubit.dart';

class MangaChapters extends StatelessWidget {
  MangaChapters({super.key, required this.manga});
  MangaView manga;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChapterCubit>(
          create: (context) => ChapterCubit(manga.chapters),
        ),
        BlocProvider<SelectionCubit>(
          create: (context) => SelectionCubit(),
        ),
      ],
      child: BlocBuilder<SelectionCubit, Set<int>>(
        builder: (context, selectedChapters) {
          final isSelectionMode = selectedChapters.isNotEmpty;
          return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              if (didPop) {
                return;
              }
              if (isSelectionMode) {
                context.read<SelectionCubit>().clearSelection();
              }
              else {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: isSelectionMode
                    ? IconButton(
                  icon: const FaIcon(FontAwesomeIcons.xmark),
                  onPressed: () {
                    context.read<SelectionCubit>().clearSelection();
                  },
                )
                    : null,
                title: isSelectionMode
                    ? Text("${selectedChapters.length} Selected")
                    : BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
                  builder: (context, libraryState) {
                    final filter = libraryState.chapterFilter;
                    final updatedMangaView = libraryState.mangaViews.firstWhere(
                          (view) => view.manga.link == manga.manga.link,
                    );
                    final filteredChapters = context.read<MangaLibraryCubit>().getFilteredChapters(updatedMangaView);
                    final filteredCount = filteredChapters.length;
                    String titleText;
                    switch (filter) {
                      case ChapterFilter.all:
                        titleText = "${manga.manga.chapters.length} Chapters";
                        break;
                      case ChapterFilter.read:
                        titleText = "$filteredCount Read";
                        break;
                      case ChapterFilter.unread:
                        titleText = "$filteredCount Unread";
                        break;
                    }
                    return Text(titleText);
                  },
                ),
                actions: isSelectionMode
                    ? [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.squareCheck),
                    tooltip: 'Select All',
                    onPressed: () {
                      final filteredChapters = context.read<MangaLibraryCubit>().getFilteredChapters(manga);
                      context.read<SelectionCubit>().selectAll(filteredChapters);
                    },
                  ),
                ]
                    : [
                  IconButton(
                    onPressed: () {
                      context.read<MangaLibraryCubit>().toggleChapterFilter();
                    },
                    icon: CircleAvatar(
                      radius: 16,
                      child: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
                        builder: (context, libraryState) {
                          final filter = libraryState.chapterFilter;
                          return filter == ChapterFilter.all
                              ? const FaIcon(FontAwesomeIcons.eyeLowVision)
                              : filter == ChapterFilter.read
                              ? const FaIcon(FontAwesomeIcons.eye)
                              : const FaIcon(FontAwesomeIcons.eyeSlash);
                        },
                      ),
                    ),
                  ),
                  BlocBuilder<ChapterCubit, List<Chapter>>(
                    builder: (context, chapterState) {
                      return IconButton(
                        onPressed: () {
                          context.read<ChapterCubit>().reverseChapters();
                        },
                        icon: CircleAvatar(
                          radius: 16,
                          child: chapterState.isEmpty ? const FaIcon(FontAwesomeIcons.angleDown) : chapterState.first.link == manga.manga.chapters.first.link
                              ? const FaIcon(FontAwesomeIcons.angleUp)
                              : const FaIcon(FontAwesomeIcons.angleDown),
                        ) ,
                      );
                    },
                  ),
                ],
              ),
              body: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
                builder: (context, libraryState) {
                  final updatedMangaView = libraryState.mangaViews.firstWhere(
                        (view) => view.manga.link == manga.manga.link,
                  );
                  return BlocBuilder<ChapterCubit, List<Chapter>>(
                    builder: (context, chapters) {
                      final filteredChapters = chapters.where((chapter) {
                        switch (libraryState.chapterFilter) {
                          case ChapterFilter.all:
                            return true;
                          case ChapterFilter.read:
                            return updatedMangaView.getIsRead(chapter.id  ?? -1);
                          case ChapterFilter.unread:
                            return !updatedMangaView.getIsRead(chapter.id  ?? -1);
                        }
                      }).toList();

                      return MangaChaptersList(
                        mangaTitle: manga.manga.title,
                        chapters: filteredChapters,
                      );
                    },
                  );
                },
              ),
              bottomSheet: isSelectionMode
                  ? BulkActionSheet(
                mangaLink: manga.link,
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
