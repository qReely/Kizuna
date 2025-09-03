import 'package:hive_ce/hive.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';

class UserManga extends HiveObject {
  final String mangaLink;

  bool isFavorite;
  int lastChapterRead;
  ReadingStatus readingStatus;
  Map<int, int> lastPageReadByChapter;
  Map<int, bool> isReadByChapter;
  Map<int, List<String>> downloadedImagePathsByChapter;
  Map<int, bool>? chapterBookmarks;
  DateTime? lastReadTimestamp;
  int? totalReadingTimeInSeconds;

  UserManga({
    required this.mangaLink,
    this.lastChapterRead = 0,
    this.isFavorite = false,
    this.readingStatus = ReadingStatus.notReading,
    this.lastPageReadByChapter = const {},
    this.isReadByChapter = const {},
    this.downloadedImagePathsByChapter = const {},
    this.lastReadTimestamp,
    this.chapterBookmarks,
    this.totalReadingTimeInSeconds = 0,
  });

  factory UserManga.fromJson(Map<String, dynamic> json) {
    return UserManga(
      mangaLink: json['manga_link'] as String,
      lastChapterRead: int.tryParse(json['last_chapter_read'].toString()) ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      readingStatus: ReadingStatus.values.elementAt(json['reading_status'] ?? 0),
      lastPageReadByChapter: (json['last_page_read_by_chapter'] as Map?)
          ?.map((key, value) => MapEntry(
          int.tryParse(key.toString()) ?? 0,
          value is int ? value : int.tryParse(value.toString()) ?? 0))
          .cast<int, int>() ??
          <int, int>{},
      isReadByChapter: (json['is_read_by_chapter'] as Map?)
          ?.map((key, value) => MapEntry(
          int.tryParse(key.toString()) ?? 0, value as bool? ?? false))
          .cast<int, bool>() ??
          <int, bool>{},
      downloadedImagePathsByChapter:
      (json['downloaded_image_paths_by_chapter'] as Map?)
          ?.map((key, value) => MapEntry(
          int.tryParse(key.toString()) ?? 0, (value as List).cast<String>()))
          .cast<int, List<String>>() ??
          <int, List<String>>{},
      lastReadTimestamp: json['last_read_timestamp'] != null
          ? DateTime.tryParse(json['last_read_timestamp'] as String)
          : null,
      chapterBookmarks: (json['chapter_bookmarks'] as Map?)
          ?.map((key, value) => MapEntry(
          int.tryParse(key.toString()) ?? 0, value as bool? ?? false))
          .cast<int, bool>(),
      totalReadingTimeInSeconds:
      json['total_reading_time_in_seconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manga_link': mangaLink,
      'last_chapter_read': lastChapterRead,
      'is_favorite': isFavorite,
      'reading_status': readingStatus.index,
      'last_page_read_by_chapter': lastPageReadByChapter,
      'is_read_by_chapter': isReadByChapter,
      'downloaded_image_paths_by_chapter': downloadedImagePathsByChapter,
      'last_read_timestamp': lastReadTimestamp?.toIso8601String(),
      'chapter_bookmarks': chapterBookmarks,
      'total_reading_time_in_seconds': totalReadingTimeInSeconds,
    };
  }

  UserManga copyWith({
    String? mangaLink,
    int? lastChapterRead,
    bool? isFavorite,
    ReadingStatus? readingStatus,
    Map<int, int>? lastPageReadByChapter,
    Map<int, bool>? isReadByChapter,
    Map<int, List<String>>? downloadedImagePathsByChapter,
    DateTime? lastReadTimestamp,
    Map<int, bool>? chapterBookmarks,
    int? totalReadingTimeInSeconds,
  }) {
    return UserManga(
      mangaLink: mangaLink ?? this.mangaLink,
      lastChapterRead: lastChapterRead ?? this.lastChapterRead,
      isFavorite: isFavorite ?? this.isFavorite,
      readingStatus: readingStatus ?? this.readingStatus,
      lastPageReadByChapter:
      lastPageReadByChapter ?? this.lastPageReadByChapter,
      isReadByChapter: isReadByChapter ?? this.isReadByChapter,
      downloadedImagePathsByChapter: downloadedImagePathsByChapter ?? this.downloadedImagePathsByChapter,
      lastReadTimestamp: lastReadTimestamp ?? this.lastReadTimestamp,
      chapterBookmarks: chapterBookmarks ?? this.chapterBookmarks,
      totalReadingTimeInSeconds: totalReadingTimeInSeconds ?? this.totalReadingTimeInSeconds,
    );
  }
}