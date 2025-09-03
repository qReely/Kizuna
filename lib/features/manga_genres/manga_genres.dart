import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/app/app_extensions.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/features/manga_genres/manga_selected_genre.dart';

class MangaGenres extends StatelessWidget {
  const MangaGenres({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
      builder: (context, state) {
        List<String> allGenres = context.read<MangaLibraryCubit>().getGenres();
        allGenres.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        final Map<String, List<String>> genresByLetter = {};
        for (var genre in allGenres) {
          final firstLetter = genre[0].toUpperCase();
          if (!genresByLetter.containsKey(firstLetter)) {
            genresByLetter[firstLetter] = [];
          }
          genresByLetter[firstLetter]!.add(genre);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Genres"),
          ),
          body: allGenres.isEmpty
              ? const EmptyPage(text: 'No genres found')
              : ListView(
            children: genresByLetter.keys.map((letter) {
              final genresInGroup = genresByLetter[letter]!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        letter,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: genresInGroup.map((genreName) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MangaSelectedGenre(selectedGenre: genreName),
                              ),
                            );
                          },
                          child: Text(
                            genreName.capitalize(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}