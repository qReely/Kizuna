import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/features/manga_search/manga_search.dart';

class MangaSearchDialog extends StatelessWidget {
  const MangaSearchDialog({super.key, this.initialQuery = "", this.replaceCurrentPage = false});
  final String initialQuery;
  final bool replaceCurrentPage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
      onPressed: () async {
        final String? query = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            TextEditingController searchController = TextEditingController();
            searchController.text = initialQuery;
            return AlertDialog(
              title: const Text('Search Manga'),
              content: TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter manga title...'),
                onSubmitted: (value) {
                  Navigator.of(context).pop(value);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Search'),
                  onPressed: () {
                    Navigator.of(context).pop(searchController.text);
                  },
                ),
              ],
            );
          },
        );

        if (query != null && query.isNotEmpty) {
          if (replaceCurrentPage) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MangaSearchPage(query: query),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaSearchPage(query: query),
              ),
            );
          }
        }
      },
    );
  }
}
