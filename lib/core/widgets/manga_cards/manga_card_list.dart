import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/features/manga_details/manga_details_page.dart';

import 'manga_card_image.dart';

class MangaCardList extends StatelessWidget {
  MangaView manga;
  final cardHeight = 100.0;
  final cardSizeMultiplier = 0.7;
  MangaCardList({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
              MangaDetailsPage(manga: manga, ),
        ),);
      },
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MangaCardImage(manga: manga, cardHeight: cardHeight, cardSizeMultiplier: cardSizeMultiplier, unreadChapters: context.read<MangaLibraryCubit>().getUnreadChapters(manga.title)),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        manga.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: cardHeight / 4,
                      ),
                      LinearProgressIndicator(
                        value: context.read<MangaLibraryCubit>().getReadChapters(manga.title) / (manga.chapters.isEmpty ? 1 : manga.chapters.length),
                        minHeight: 8,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          manga.lastChapterRead > 0 ?
                          Text(
                            textAlign: TextAlign.start,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            manga.chapters.where((chapter) => chapter.id == manga.lastChapterRead).first.title,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ):
                          const SizedBox(),
                          SizedBox(
                            width: cardHeight,
                            child: Text(
                              textAlign: TextAlign.end,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              manga.manga.lastChapter ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}