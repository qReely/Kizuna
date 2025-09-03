import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/app/app_extensions.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/manga_views/manga_grid_view.dart';
import 'package:manga_reader_app/core/widgets/manga_views/manga_list_view.dart';
import 'package:manga_reader_app/core/widgets/scaffold_wrapper/scaffold_wrapper.dart';
import 'package:manga_reader_app/core/widgets/pagination_controls/pagination_controls.dart';
import 'package:manga_reader_app/features/manga_genres/manga_genres_cubit.dart';
import 'package:manga_reader_app/features/manga_genres/manga_genres_state.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';

class MangaSelectedGenre extends StatelessWidget {
  final String selectedGenre;
  const MangaSelectedGenre({super.key, required this.selectedGenre});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenresTabCubit(),
      child: ScaffoldWrapper(
        title: selectedGenre.capitalize(),
        showActions: true,
        showSearch: false,
        showBottomNavBar: false,
        body: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
          builder: (context, libraryState) {
            final List<MangaView> filteredMangaViews = libraryState.mangaViews
                .where(
                  (mangaView) => mangaView.manga.genres.any(
                    (genre) =>
                genre.name.toLowerCase() == selectedGenre.toLowerCase(),
              ),
            ).toList();

            if (libraryState.isLoading) {
              return const LoadingAnimation(text: "Loading Manga");
            }

            if (libraryState.errorMessage != null) {
              return const ErrorPage();
            }

            if (filteredMangaViews.isEmpty) {
              return const EmptyPage(text: "No manga found for this genre");
            }

            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return BlocBuilder<GenresTabCubit, GenresTabState>(
                  builder: (context, genreState) {
                    final int totalPages = (filteredMangaViews.length / context.read<SettingsCubit>().state.mangasPerPage).ceil();
                    final int startIndex = (genreState.currentPage - 1) * context.read<SettingsCubit>().state.mangasPerPage;
                    final int endIndex = startIndex + context.read<SettingsCubit>().state.mangasPerPage;
                    final List<MangaView> paginatedItems = filteredMangaViews.sublist(
                      startIndex,
                      endIndex > filteredMangaViews.length ? filteredMangaViews.length : endIndex,
                    );

                    return Scaffold(
                      body: SingleChildScrollView(
                        child: BlocListener<GenresTabCubit, GenresTabState>(
                            listenWhen: (previous, current) => previous.currentPage != current.currentPage,
                            listener: (context, state) {
                              if (Scrollable.of(context) != null) {
                                Scrollable.of(context)!.position.jumpTo(0.0);
                              }
                            },
                            child: libraryState.isGridView
                                ? MangaGridView(mangas: paginatedItems)
                                : MangaListView(mangas: paginatedItems)),
                      ),
                      bottomNavigationBar: totalPages > 1
                          ? PaginationControls(
                        currentPage: genreState.currentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          context.read<GenresTabCubit>().changePage(page);
                        },
                      )
                          : null,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}