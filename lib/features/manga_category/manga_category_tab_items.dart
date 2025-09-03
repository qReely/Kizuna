import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/manga_views/manga_grid_view.dart';
import 'package:manga_reader_app/core/widgets/manga_views/manga_list_view.dart';
import 'package:manga_reader_app/core/widgets/pagination_controls/pagination_controls.dart';
import 'package:manga_reader_app/features/manga_category/manga_category_tab_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';

import 'manga_category_tab_state.dart';

class CategoryTabItems extends StatelessWidget {
  final List<MangaView> filteredMangaViews;
  const CategoryTabItems({super.key, required this.filteredMangaViews});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MangaCategoryTabCubit(),
      child: Scaffold(
        body: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
          builder: (context, libraryState) {

            if (libraryState.isLoading) {
              return const LoadingAnimation(text: "Loading Manga");
            }

            if (libraryState.errorMessage != null) {
              return const ErrorPage();
            }

            if (filteredMangaViews.isEmpty) {
              return const EmptyPage(text: 'No manga inside this category.');
            }

            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return BlocBuilder<MangaCategoryTabCubit, MangaCategoryTabState>(
                  builder: (context, categoryTabState) {
                    final int totalPages = (filteredMangaViews.length / context.read<SettingsCubit>().state.mangasPerCategoryPage).ceil();
                    final int startIndex = (categoryTabState.currentPage - 1) * context.read<SettingsCubit>().state.mangasPerCategoryPage;
                    final int endIndex = startIndex + context.read<SettingsCubit>().state.mangasPerCategoryPage;
                    final List<MangaView> paginatedItems = filteredMangaViews.sublist(
                      startIndex,
                      endIndex > filteredMangaViews.length ? filteredMangaViews.length : endIndex,
                    );

                    return Scaffold(
                      body: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        dragStartBehavior: DragStartBehavior.down,
                        child: BlocListener<MangaCategoryTabCubit, MangaCategoryTabState>(
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
                        currentPage: categoryTabState.currentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          context.read<MangaCategoryTabCubit>().changePage(page);
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