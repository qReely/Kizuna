import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/data/services/manga_api_service.dart';
import 'package:manga_reader_app/data/services/notification_service.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';

class UserMangaRepository {
  final IsolatedBox<UserManga> _userMangaBox;
  final IsolatedBox<Manga> _mangaBox;
  final MangaApiService _mangaApiService;

  UserMangaRepository(this._userMangaBox, this._mangaBox, this._mangaApiService);

  Future<List<MangaView>> getCombinedMangaList() async {
    final List<Manga> allManga = (await _mangaBox.values).toList();
    final Map<String, UserManga> userMangaMap = {
      for (var userManga in await _userMangaBox.values) userManga.mangaLink: userManga
    };

    List<MangaView> views = allManga.map((manga) {
      final userManga = userMangaMap[manga.link];
      return MangaView(manga: manga, userManga: userManga);
    }).toList();
    views.sort((a, b) => a.order!.compareTo(b.order!));
    return views;
  }

  Future<void> fetchAndStoreAllMangas(SettingsState settings) async {
    if(settings.isUpdateWifiOnly) {
      final connectivity = await Connectivity().checkConnectivity();
      if(!connectivity.contains(ConnectivityResult.wifi)) {
        return;
      }
    }
    try {
      NotificationService();
      final allMangas = await _mangaApiService.fetchAllMangas();
      int updated = 0;
      int notificationIdCounter = 1;
      for (final newManga in allMangas) {
        final existingManga = await _mangaBox.get(newManga.link);
        final userManga = await _userMangaBox.get(newManga.link);

        if (existingManga != null) {
          if(newManga.chapters.length > existingManga.chapters.length) {
            updated++;
            if (settings.notifyIfFavoriteMangaUpdated && userManga != null && userManga.isFavorite) {
              notificationIdCounter += 1;
              final newChapterCount = newManga.chapters.length - existingManga.chapters.length;
              final chapterWord = newChapterCount > 1 ? 'chapters have' : 'chapter has';
              await NotificationService().showNotification(
                  newManga.title,
                  '$newChapterCount new $chapterWord been released!',
                  notificationIdCounter,
              );
            }
          }
        }
        await _mangaBox.put(newManga.link, newManga);
      }
      if(settings.showNotificationsAfterUpdate) {
        if(updated > 0) {
          await NotificationService().showGroupSummaryNotification(updated);
        }
        else{
          await NotificationService().showNotification("Library Update", "No new chapters were found.", 0);
        }

      }


      await _mangaBox.clear();
      for (var manga in allMangas) {
        await _mangaBox.put(manga.link, manga);
      }
      if(kDebugMode) {
        debugPrint('Fetched and stored mangas from Supabase');
      }
    } catch (e) {
      if(kDebugMode) {
        debugPrint('Failed to fetch and store mangas from Supabase: $e');
      }
    }
  }

  Stream<List<MangaView>> getCombinedMangaStream() {
    return _userMangaBox.watch().asyncMap((event) => getCombinedMangaList());
  }

  Future<void> saveAllManga(List<Manga> mangas) async {
    for (var manga in mangas) {
      await _mangaBox.put(manga.link, manga);
    }
  }

  Future<UserManga?> getUserManga(String mangaLink) async {
    return _userMangaBox.get(mangaLink);
  }

  Future<Manga?> getManga(String mangaLink) async {
    return await _mangaBox.get(mangaLink);
  }

  Future<String> getMangaLinkFromChapterId(int chapterId) async {
    final userManga = (await _userMangaBox.values).firstWhere((manga) => manga.lastChapterRead == chapterId);
    return userManga.mangaLink;
  }

  Future<void> saveUserManga(UserManga userManga) async {
    await _userMangaBox.put(userManga.mangaLink, userManga);
  }

  Future<void> updateChapterBookmark({
    required String mangaLink,
    required Map<int, bool> bookmarks,
  }) async {
    UserManga? userManga = await _userMangaBox.get(mangaLink) ??
        UserManga(
          mangaLink: mangaLink,
          lastPageReadByChapter: {},
          isReadByChapter: {},
          downloadedImagePathsByChapter: {},
          chapterBookmarks: {},
        );
    userManga.chapterBookmarks = {...?userManga.chapterBookmarks, ...bookmarks};
    await _userMangaBox.put(mangaLink, userManga);
  }

  Future<void> updateReadingStatus({
    required String mangaLink,
    required ReadingStatus newStatus,
  }) async {
    final userManga = await _userMangaBox.get(mangaLink);
    if (userManga != null) {
      userManga.readingStatus = newStatus;
      await _userMangaBox.put(mangaLink, userManga);
    } else {
      final newUserManga = UserManga(
        mangaLink: mangaLink,
        isFavorite: false,
        readingStatus: newStatus,
        lastPageReadByChapter: {},
        isReadByChapter: {},
        downloadedImagePathsByChapter: {},
      );
      await _userMangaBox.put(mangaLink, newUserManga);
    }
  }

  Future<void> updateReadingTime({
    required String mangaLink,
    required int seconds,
  }) async {
    final userManga = await _userMangaBox.get(mangaLink) ??
        UserManga(
          mangaLink: mangaLink,
          lastPageReadByChapter: {},
          isReadByChapter: {},
          downloadedImagePathsByChapter: {},
          totalReadingTimeInSeconds: 0,
        );

    userManga.totalReadingTimeInSeconds =
        (userManga.totalReadingTimeInSeconds ?? 0) + seconds;

    await _userMangaBox.put(mangaLink, userManga);
  }

  Future<void> updateReadingProgress({
    required String mangaLink,
    required int chapterId,
    required int lastPageRead,
    bool? isRead,
  }) async {
    final userManga = await _userMangaBox.get(mangaLink) ??
        UserManga(
          mangaLink: mangaLink,
          lastPageReadByChapter: {},
          isReadByChapter: {},
          downloadedImagePathsByChapter: {},
        );

    userManga.lastPageReadByChapter[chapterId] = lastPageRead;
    userManga.isReadByChapter[chapterId] = (isRead ?? userManga.isReadByChapter[chapterId]) ?? false;
    userManga.lastReadTimestamp = DateTime.now();
    userManga.lastChapterRead = chapterId;

    await _userMangaBox.put(mangaLink, userManga);
  }

  Future<void> toggleFavorite(String mangaLink) async {
    var userManga = await _userMangaBox.get(mangaLink) ??
        UserManga(
          mangaLink: mangaLink,
          isFavorite: false,
          readingStatus: ReadingStatus.notReading,
          lastPageReadByChapter: {},
          isReadByChapter: {},
          downloadedImagePathsByChapter: {},
        );
    userManga.isFavorite = !userManga.isFavorite;
    _userMangaBox.put(mangaLink, userManga);
  }

  Future<bool> isChapterDownloaded(String mangaLink, int chapterId) async {
    final userManga = await _userMangaBox.get(mangaLink);
    if (userManga == null) return false;
    return userManga.downloadedImagePathsByChapter.containsKey(chapterId);
  }

  Future<List<String>> downloadedChapterImages(String mangaLink, int chapterId) async {
    final userManga = await _userMangaBox.get(mangaLink);
    if(userManga == null) return [];
    return userManga.downloadedImagePathsByChapter[chapterId] ?? [];
  }

  Future<void> deleteDownloadedChapter(String mangaLink, int chapterId) async {
    final userManga = await _userMangaBox.get(mangaLink);
    if(userManga == null) return;
    userManga.downloadedImagePathsByChapter.remove(chapterId);
    await _userMangaBox.put(mangaLink, userManga);
  }

  Future<void> deleteDownloadedChapters(String mangaLink) async {
    final userManga = await _userMangaBox.get(mangaLink);
    if(userManga == null) return;
    userManga.downloadedImagePathsByChapter.clear();
    await _userMangaBox.put(mangaLink, userManga);
  }

  Future<void> updateDownloadedChapterPaths({
    required String mangaLink,
    required int chapterId,
    required List<String> downloadedPaths,
  }) async {
    final userManga = await _userMangaBox.get(mangaLink) ??
        UserManga(
          mangaLink: mangaLink,
          isFavorite: false,
          readingStatus: ReadingStatus.notReading,
          lastPageReadByChapter: {},
          isReadByChapter: {},
          downloadedImagePathsByChapter: {},
        );

    userManga.downloadedImagePathsByChapter[chapterId] = downloadedPaths;
    await _userMangaBox.put(mangaLink, userManga);
  }

  Future<List<UserManga>> getAllDownloadedUserManga() async {
    final List<UserManga> allUserMangas = (await _userMangaBox.values).toList();
    return allUserMangas.where((manga) {
      return manga.downloadedImagePathsByChapter.isNotEmpty;
    }).toList();
  }

  Future<List<Manga>> getAllDownloadedManga() async {
    final List<Manga> allMangas = (await _mangaBox.values).toList();
    final List<UserManga> downloadedMangas = await getAllDownloadedUserManga();
    return allMangas.where((manga) {
      return downloadedMangas.any((downloadedManga) => downloadedManga.mangaLink == manga.link);
    }).toList();
  }

  Future<String> getMangaTitle(String mangaLink) async {
    final manga = (await _mangaBox.values).firstWhere((manga) => manga.link == mangaLink);
    return manga.title;
  }

  Future<String> getMangaImage(String mangaLink) async  {
    return (await _mangaBox.values).firstWhere((manga) => manga.link == mangaLink).image ?? "";
  }
}