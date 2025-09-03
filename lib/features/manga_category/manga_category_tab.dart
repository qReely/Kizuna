import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';

import 'manga_category_tab_items.dart';

class MangaCategoryTab extends StatelessWidget {
  final ReadingStatus? status;

  const MangaCategoryTab({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
      builder: (context, state) {
        List<MangaView> filteredMangas;
        if(status != null) {
          filteredMangas = context.read<MangaLibraryCubit>().statusFilter(status!);
        }
        else {
          filteredMangas = context.read<MangaLibraryCubit>().getFavorites();
        }
        return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("${filteredMangas.length} manga${filteredMangas.length > 1 ? "s" : ""}"),
                ),
                Expanded(
                    child: CategoryTabItems(filteredMangaViews: filteredMangas,)
                ),
              ],
            )
        );
      }
    );
  }
}
