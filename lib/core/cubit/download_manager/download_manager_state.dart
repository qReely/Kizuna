import 'package:equatable/equatable.dart';
import 'package:manga_reader_app/core/enums/download_manga_sort_option.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';

class DownloadedMangaView extends Equatable {
  final UserManga userManga;
  final Manga manga;
  final double sizeInMB;

  const DownloadedMangaView({
    required this.userManga,
    required this.manga,
    required this.sizeInMB,
  });

  @override
  List<Object> get props => [userManga, manga, sizeInMB];
}

class DownloadedChapterView extends Equatable {
  final Chapter chapter;
  final String mangaLink;
  final bool isRead;
  final double sizeInMB;

  const DownloadedChapterView({
    required this.mangaLink,
    required this.chapter,
    required this.isRead,
    required this.sizeInMB,
  });

  @override
  List<Object> get props => [chapter, isRead, sizeInMB, mangaLink];
}

class DownloadManagerState extends Equatable {
  final List<UserManga> downloadedMangas;
  final double totalDownloadedSize;
  final bool isLoading;
  final String? errorMessage;
  final SortOption sortOption;
  final bool isAscending;
  final List<DownloadedMangaView> downloadedMangaDetails;
  final List<DownloadedChapterView> downloadedChapterDetails;


  List<DownloadedChapterView> downloadedChapterDetailsFromManga(String mangaLink) {
    return downloadedChapterDetails.where((view) => view.mangaLink == mangaLink).toList();
  }

  const DownloadManagerState({
    required this.downloadedMangas,
    this.totalDownloadedSize = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.sortOption = SortOption.title,
    this.isAscending = true,
    this.downloadedMangaDetails = const [],
    this.downloadedChapterDetails = const [],
  });

  DownloadManagerState copyWith({
    List<UserManga>? downloadedMangas,
    double? totalDownloadedSize,
    bool? isLoading,
    String? errorMessage,
    SortOption? sortOption,
    bool? isAscending,
    List<DownloadedMangaView>? downloadedMangaDetails,
    List<DownloadedChapterView>? downloadedChapterDetails,
  }) {
    return DownloadManagerState(
      downloadedMangas: downloadedMangas ?? this.downloadedMangas,
      totalDownloadedSize: totalDownloadedSize ?? this.totalDownloadedSize,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      isAscending: isAscending ?? this.isAscending,
      downloadedChapterDetails: downloadedChapterDetails ?? this.downloadedChapterDetails,
      downloadedMangaDetails: downloadedMangaDetails ?? this.downloadedMangaDetails,
    );
  }

  @override
  List<Object?> get props => [
    downloadedMangas,
    totalDownloadedSize,
    isLoading,
    errorMessage,
    sortOption,
    isAscending,
    downloadedMangaDetails,
    downloadedChapterDetails
  ];
}