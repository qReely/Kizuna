import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:manga_reader_app/core/models/authors_model.dart';
import 'package:manga_reader_app/core/models/artists_model.dart';
import 'package:manga_reader_app/core/models/genres_model.dart';

class MangaView {
  final Manga manga;
  final UserManga? userManga;

  MangaView({required this.manga, this.userManga});

  String get title => manga.title;
  String get link => manga.link;
  String? get image => manga.image;
  String? get status => manga.status;
  double? get rating => manga.rating;
  String? get synopsis => manga.synopsis;
  List<Author> get authors => manga.authors;
  List<Artist> get artists => manga.artists;
  List<Genre> get genres => manga.genres;
  List<Chapter> get chapters => manga.chapters;
  int? get order => manga.order;
  String? get type => manga.type;

  bool get isFavorite => userManga?.isFavorite ?? false;
  ReadingStatus get readingStatus => userManga?.readingStatus ?? ReadingStatus.notReading;
  int get lastChapterRead => userManga?.lastChapterRead ?? 0;
  DateTime? get lastReadTimestamp => userManga?.lastReadTimestamp;
  Map<int, int> get lastPageReadByChapter => userManga?.lastPageReadByChapter ?? {};
  Map<int, bool> get chapterBookmarks => userManga?.chapterBookmarks ?? {};
  int get totalReadingTimeInSeconds => userManga?.totalReadingTimeInSeconds ?? 0;


  Map<int, bool> get isReadByChapter => userManga?.isReadByChapter ?? {};
  Map<int, List<String>> get downloadedImagePathsByChapter => userManga?.downloadedImagePathsByChapter ?? {};

  int getLastPageRead(int chapterId) {
    return userManga?.lastPageReadByChapter[chapterId] ?? 0;
  }

  bool getIsRead(int chapterId) {
    return userManga?.isReadByChapter[chapterId] ?? false;
  }

  MangaView copyWith({
    Manga? manga,
    UserManga? userManga,
  }) {
    return MangaView(
      manga: manga ?? this.manga,
      userManga: userManga ?? this.userManga,
    );
  }

}