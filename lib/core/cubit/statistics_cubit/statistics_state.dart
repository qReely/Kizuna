import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:equatable/equatable.dart';

class StatisticsState extends Equatable {
  final int totalChaptersRead;
  final int totalFavoriteManga;
  final int totalReadingTimeInSeconds;
  final List<MangaView> mostReadManga;
  final bool isLoading;

  const StatisticsState({
    this.totalChaptersRead = 0,
    this.totalFavoriteManga = 0,
    this.totalReadingTimeInSeconds = 0,
    this.mostReadManga = const [],
    this.isLoading = true,
  });

  StatisticsState copyWith({
    int? totalChaptersRead,
    int? totalFavoriteManga,
    int? totalReadingTimeInSeconds,
    List<MangaView>? mostReadManga,
    bool? isLoading,
  }) {
    return StatisticsState(
      totalChaptersRead: totalChaptersRead ?? this.totalChaptersRead,
      totalFavoriteManga: totalFavoriteManga ?? this.totalFavoriteManga,
      totalReadingTimeInSeconds: totalReadingTimeInSeconds ?? this.totalReadingTimeInSeconds,
      mostReadManga: mostReadManga ?? this.mostReadManga,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [
    totalChaptersRead,
    totalFavoriteManga,
    totalReadingTimeInSeconds,
    mostReadManga,
    isLoading,
  ];
}