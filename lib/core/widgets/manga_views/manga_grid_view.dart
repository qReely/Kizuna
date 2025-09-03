import 'package:flutter/material.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import '../manga_cards/manga_card_grid.dart';

class MangaGridView extends StatelessWidget {
  MangaGridView({super.key, required this.mangas, this.emptyText = "No mangas inside."});
  List<MangaView> mangas;
  String emptyText;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    //0.45918367346938777
    final cardWidth = screenWidth * 0.25;
    final cardHeight = cardWidth * (230 / 100) / (aspectRatio + 10/19);

    return mangas.isNotEmpty ? GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 16.0,
      shrinkWrap: true,
      childAspectRatio: cardWidth / cardHeight,
      padding: const EdgeInsets.all(8.0),
      children: mangas.map((manga) {
        return MangaCard(
          manga: manga,
        );
      }).toList(),
    ) : EmptyPage(text: emptyText);
  }
}
