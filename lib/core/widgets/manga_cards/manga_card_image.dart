import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';

class MangaCardImage extends StatelessWidget {
  MangaCardImage({super.key, required this.manga, required this.cardHeight, required this.cardSizeMultiplier, required this.unreadChapters});

  MangaView manga;
  final double cardHeight;
  final double cardSizeMultiplier;
  int unreadChapters;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            CachedNetworkImage(
              imageUrl: manga.image!,
              imageBuilder: (context, imageProvider) =>
                  Container(
                    height: cardHeight,
                    width: cardHeight * cardSizeMultiplier,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SizedBox(
                    width: cardHeight * cardSizeMultiplier,
                    height: cardHeight,
                    child: Center(
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    ),
                  ),
              errorWidget: (context, url, error) =>
                  Container(
                    height: cardHeight,
                    width: cardHeight * cardSizeMultiplier,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey[700],
                        size: cardHeight * cardSizeMultiplier / 2,
                      ),
                    ),
                  ),
            ),
            Visibility(
              visible: manga.status == "Completed" && context.read<SettingsCubit>().state.isDisplayCompletedStatus,
              child: Container(
                width: cardHeight * cardSizeMultiplier,
                alignment: Alignment.topCenter,
                color: Theme.of(context).dividerColor,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Completed", style: const TextStyle().copyWith(fontSize: 12),),
                ),
              ),
            ),
            Visibility(
              visible: context.read<SettingsCubit>().state.isDisplayUnreadChapters,
              child: Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 28,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.deepPurple,
                  ),
                  child: Center(
                    child: Text(
                      "$unreadChapters",
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: manga.isFavorite && context.read<SettingsCubit>().state.isDisplayFavoriteStatus,
              child: Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.deepPurple,
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.solidHeart, size: 8),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: manga.readingStatus.index != 0 && context.read<SettingsCubit>().state.isDisplayReadingStatus,
              child: Container(
                height: 16,
                alignment: Alignment.center,
                width: cardHeight * cardSizeMultiplier,
                margin: EdgeInsets.only(top: cardHeight - 16),
                color: manga.readingStatus.color,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(manga.readingStatus.name, style: const TextStyle().copyWith(fontSize: 12),),
                ),
              ),
            ),

          ],
        );
      }
    );
  }
}