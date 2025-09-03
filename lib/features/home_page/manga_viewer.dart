import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/manga_views/manga_grid_view.dart';
import 'package:manga_reader_app/core/widgets/manga_views/manga_list_view.dart';
import 'package:manga_reader_app/core/widgets/pagination_controls/pagination_controls.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';

class MangaViewer extends StatelessWidget {
  const MangaViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
       return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
         builder: (context, state) {
           if (state.isLoading) {
             return const LoadingAnimation(text: "Loading Manga");
           }
           if (state.errorMessage != null) {
             return ErrorPage(errorMessage: state.errorMessage,);
           }

           final allManga = state.mangaViews;

           final int itemsPerPage = context.read<SettingsCubit>().state.mangasPerPage;
           final int totalPages = (allManga.length / itemsPerPage).ceil();

           final int startIndex = (state.currentPage - 1) * itemsPerPage;
           final int endIndex = startIndex + itemsPerPage;
           final currentPageManga = allManga.sublist(
             startIndex,
             endIndex > allManga.length ? allManga.length : endIndex,
           );
           return Scaffold(
             body: SingleChildScrollView(
               child: BlocListener<MangaLibraryCubit, MangaLibraryState>(
                   listenWhen: (previous, current) => previous.currentPage != current.currentPage,
                   listener: (context, state) {
                     if (Scrollable.of(context) != null) {
                       Scrollable.of(context)!.position.jumpTo(0.0);
                     }
                   },
                   child: state.isGridView
                       ? MangaGridView(mangas: currentPageManga)
                       : MangaListView(mangas: currentPageManga)
               ),
             ),
             bottomNavigationBar: totalPages > 1
                 ? PaginationControls(
               currentPage: state.currentPage,
               totalPages: totalPages,
               onPageChanged: (page) {
                 context.read<MangaLibraryCubit>().changePage(page);
               },
             )
                 : null,
           );
         },
       );
      }
    );
  }
}