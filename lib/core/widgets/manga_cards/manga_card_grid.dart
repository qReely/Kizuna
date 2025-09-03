import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/features/manga_details/manga_details_page.dart';

import 'manga_card_image.dart';

class MangaCard extends StatelessWidget {
  MangaCard({super.key, required this.manga});
  MangaView manga;
  final double cardHeight = 150;
  final double cardSizeMultiplier = 0.66;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MangaDetailsPage(manga: manga, ),
        ),);
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8.0)),
              child: MangaCardImage(manga: manga, cardHeight: cardHeight, cardSizeMultiplier: cardSizeMultiplier, unreadChapters: context.read<MangaLibraryCubit>().getUnreadChapters(manga.title),),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 38.0,
                      child: Text(
                        manga.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8,),
                    LinearProgressIndicator(
                      value: context.read<MangaLibraryCubit>().getReadChapters(manga.title) / (manga.chapters.isEmpty ? 1 : manga.chapters.length),
                    ),
                    const SizedBox(height: 8,),
                    Text(
                      manga.manga.lastChapter ?? "",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600], overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
