import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/manga_cards/manga_card_image.dart';
import 'package:manga_reader_app/features/manga_details/manga_details_page.dart';
import 'package:manga_reader_app/app/app_functions.dart';

class MangaCarousel extends StatelessWidget {
  final List<MangaView> mangas;
  final double height;
  final double multiplier;

  const MangaCarousel({
    super.key,
    required this.mangas,
    this.height = 180.0,
    this.multiplier = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          final manga = mangas[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => MangaDetailsPage(manga: manga),
                ),
              );
            },
            child: Container(
              width: height * multiplier,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Stack(
                children: [
                  MangaCardImage(manga: manga, cardHeight: height, cardSizeMultiplier: multiplier, unreadChapters: context.read<MangaLibraryCubit>().getUnreadChapters(manga.title),),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.black.withOpacity(0.6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manga.manga.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatIcon(
                                icon: FontAwesomeIcons.bookOpen,
                                value: "${manga.userManga!.isReadByChapter.values.where((isRead) => isRead).length}",
                              ),
                              _buildStatIcon(
                                icon: FontAwesomeIcons.hourglassHalf,
                                value: prettyDurationOnlyOne(Duration(seconds: manga.userManga!.totalReadingTimeInSeconds!)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatIcon({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        FaIcon(icon, size: 12, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}