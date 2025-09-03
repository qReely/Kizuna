import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/features/manga_chapters/manga_chapter_tile.dart';

import 'manga_chapter_selection_cubit.dart';

class MangaChaptersList extends StatelessWidget {
  MangaChaptersList({super.key,required this.mangaTitle, required this.chapters});
  final String mangaTitle;
  List<Chapter> chapters;

  @override
  Widget build(BuildContext context) {
    final selectionCubit = context.watch<SelectionCubit>();

    return chapters.isNotEmpty
        ? ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: chapters.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isSelected = selectionCubit.state.contains(chapter.id);
        final isSelectionMode = selectionCubit.state.isNotEmpty;

        return MangaChapterTile(
          mangaTitle: mangaTitle,
          chapter: chapter,
          chapters: chapters,
          isSelected: isSelected,
          isSelectionMode: isSelectionMode,
        );
      },
    )
        : const EmptyPage(text: "No chapters found");
  }
}
