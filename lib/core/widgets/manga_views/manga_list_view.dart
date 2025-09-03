import 'package:flutter/material.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/manga_cards/manga_card_list.dart';

class MangaListView extends StatelessWidget {
  MangaListView({super.key, required this.mangas,  this.emptyText = "No mangas inside."});
  String emptyText;
  List<MangaView> mangas;
  @override
  Widget build(BuildContext context) {
    return mangas.isNotEmpty ? ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mangas.length,
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return MangaCardList(
          manga: mangas.elementAt(index),
        );
      },
    ) : EmptyPage(text: emptyText);
  }
}