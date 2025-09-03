import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/scaffold_wrapper/scaffold_wrapper.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';
import '../../core/widgets/manga_views/manga_grid_view.dart';
import '../../core/widgets/manga_views/manga_list_view.dart';
import '../../core/widgets/pagination_controls/pagination_controls.dart';
import 'manga_search_cubit.dart';
import 'manga_search_state.dart';

class MangaSearchPage extends StatelessWidget {
  final String query;
  const MangaSearchPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: query,
      showBottomNavBar: false,
      body: BlocProvider(
        create: (context) => SearchPageCubit(),
        child: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
          builder: (context, libraryState) {
            final List<MangaView> filteredMangaViews = libraryState.mangaViews
              .where(
                (mangaView) => mangaView.manga.title.toLowerCase().contains(query.toLowerCase()),
            ).toList();

            if (libraryState.isLoading) {
              return const LoadingAnimation(text: "Loading Manga");
            }

            if (libraryState.errorMessage != null) {
              return const ErrorPage();
            }

            if (filteredMangaViews.isEmpty) {
              return const EmptyPage(text: "No manga found for this query");
            }

            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return BlocBuilder<SearchPageCubit, SearchPageState>(
                  builder: (context, searchState) {
                    final int totalPages = (filteredMangaViews.length / context.read<SettingsCubit>().state.mangasPerPage).ceil();
                    final int startIndex = (searchState.currentPage - 1) * context.read<SettingsCubit>().state.mangasPerPage;
                    final int endIndex = startIndex + context.read<SettingsCubit>().state.mangasPerPage;
                    final List<MangaView> paginatedItems = filteredMangaViews.sublist(
                      startIndex,
                      endIndex > filteredMangaViews.length ? filteredMangaViews.length : endIndex,
                    );
                    return Scaffold(
                      body: SingleChildScrollView(
                        child: BlocListener<SearchPageCubit, SearchPageState>(
                            listenWhen: (previous, current) => previous.currentPage != current.currentPage,
                            listener: (context, state) {
                              if (Scrollable.of(context) != null) {
                                Scrollable.of(context)!.position.jumpTo(0.0);
                              }
                            },
                            child: libraryState.isGridView
                                ? MangaGridView(mangas: paginatedItems)
                                : MangaListView(mangas: paginatedItems)
                        ),
                      ),
                      bottomNavigationBar: PaginationControls(
                        currentPage: searchState.currentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          context.read<SearchPageCubit>().changePage(page);
                        },
                      ),
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