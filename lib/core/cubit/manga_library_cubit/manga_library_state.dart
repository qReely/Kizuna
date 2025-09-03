import 'package:manga_reader_app/core/enums/chapter_filter_enum.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';

class MangaLibraryState {
  final bool isLoading;
  final bool isGridView;
  final int currentPage;
  final String? errorMessage;
  final List<MangaView> mangaViews;
  final ChapterFilter chapterFilter;

  const MangaLibraryState({
    this.isLoading = true,
    this.isGridView = true,
    this.currentPage = 1,
    this.errorMessage,
    this.mangaViews = const [],
    this.chapterFilter = ChapterFilter.all,
  });

  MangaLibraryState copyWith({
    bool? isLoading,
    bool? isGridView,
    int? currentPage,
    String? errorMessage,
    List<MangaView>? mangaViews,
    ChapterFilter? chapterFilter,
  }) {
    return MangaLibraryState(
      isLoading: isLoading ?? this.isLoading,
      isGridView: isGridView ?? this.isGridView,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      mangaViews: mangaViews ?? this.mangaViews,
      chapterFilter: chapterFilter ?? this.chapterFilter,
    );
  }
}