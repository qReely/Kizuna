import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/statistics_cubit/statistics_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/app/app_extensions.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(const StatisticsState());

  void calculateStatistics(List<MangaView> mangaViews) {
    if (mangaViews.isEmpty) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    final int totalChaptersRead = mangaViews.fold<int>(
      0, (sum, mangaView) => sum + (mangaView.isReadByChapter.values.where((isRead) => isRead).length),
    );

    final int totalReadingTime = mangaViews.fold<int>(
      0, (sum, mangaView) => sum + (mangaView.userManga?.totalReadingTimeInSeconds ?? 0),
    );

    final int totalFavoriteManga = mangaViews.where((manga) => manga.isFavorite).length;

    final List<MangaView> mostReadManga = mangaViews
        .where((manga) => manga.userManga != null)
        .sorted((a, b) => (b.userManga!.totalReadingTimeInSeconds!).compareTo(a.userManga!.totalReadingTimeInSeconds!))
        .take(5)
        .toList();

    emit(state.copyWith(
      totalChaptersRead: totalChaptersRead,
      totalFavoriteManga: totalFavoriteManga,
      totalReadingTimeInSeconds: totalReadingTime,
      mostReadManga: mostReadManga,
      isLoading: false,
    ));
  }
}