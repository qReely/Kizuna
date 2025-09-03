import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/enums/chapter_filter_enum.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'manga_library_state.dart';
import 'package:collection/collection.dart';

class MangaLibraryCubit extends Cubit<MangaLibraryState> {
  final UserMangaRepository _userMangaRepository;
  StreamSubscription? _mangaSubscription;

  MangaLibraryCubit(this._userMangaRepository, bool isListMode) : super(MangaLibraryState(isGridView: !isListMode));

  @override
  Future<void> close() {
    _mangaSubscription?.cancel();
    return super.close();
  }

  Future<void> fetchLatestUpdates(SupabaseClient repository, SettingsState settings) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _userMangaRepository.fetchAndStoreAllMangas(settings);
      await loadManga();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error message'));
    }
  }

  Future<void> loadManga() async {
    emit(state.copyWith(isLoading: true));
    try {
      final mangaViews = await _userMangaRepository.getCombinedMangaList();
      emit(state.copyWith(isLoading: false, mangaViews: mangaViews));

      _mangaSubscription = _userMangaRepository.getCombinedMangaStream().listen(
            (updatedMangaViews) {
          emit(state.copyWith(mangaViews: updatedMangaViews));
        },
        onError: (error) {
          emit(state.copyWith(errorMessage: 'Error message from stream'));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error message'));
    }
  }

  void toggleView() {
    emit(state.copyWith(isGridView: !state.isGridView));
  }

  void updateStatus(String mangaLink, ReadingStatus newStatus) {
    _userMangaRepository.updateReadingStatus(mangaLink: mangaLink, newStatus: newStatus);
  }

  void changePage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  void toggleFavorite(String mangaLink) async {
    _userMangaRepository.toggleFavorite(mangaLink);
  }



  void toggleChapterFilter() {
    ChapterFilter nextFilter;
    switch (state.chapterFilter) {
      case ChapterFilter.all:
        nextFilter = ChapterFilter.read;
        break;
      case ChapterFilter.read:
        nextFilter = ChapterFilter.unread;
        break;
      case ChapterFilter.unread:
        nextFilter = ChapterFilter.all;
        break;
    }
    emit(state.copyWith(chapterFilter: nextFilter));
  }

  bool isChapterBookmarked(String mangaLink, int chapterId) {
    var mangaView = state.mangaViews.firstWhereOrNull((view) => view.manga.link == mangaLink);
    if(mangaView != null) {
      if(mangaView.chapterBookmarks.containsKey(chapterId)) {
        return mangaView.chapterBookmarks[chapterId]!;
      }
    }
    return false;
  }

  void updateTotalReadingTime({
    required String mangaLink,
    required int seconds,
  }) async {
    await _userMangaRepository.updateReadingTime(
      mangaLink: mangaLink,
      seconds: seconds,
    );
  }

  Future<void> toggleChapterBookmark(String mangaLink, List<int> chapterIds, {bool? isBookmarked}) async {
    final Map<int, bool> newBookmarks = {};

    final currentMangaView = state.mangaViews.firstWhereOrNull((view) => view.manga.link == mangaLink);
    if (currentMangaView == null) {
      return;
    }

    for (final chapterId in chapterIds) {
      final bool currentStatus = currentMangaView.userManga?.chapterBookmarks?[chapterId] ?? false;
      newBookmarks[chapterId] = isBookmarked ?? !currentStatus;
    }

    await _userMangaRepository.updateChapterBookmark(
      mangaLink: mangaLink,
      bookmarks: newBookmarks,
    );
  }

  List<Chapter> getFilteredChapters(MangaView mangaView) {
    switch (state.chapterFilter) {
      case ChapterFilter.all:
        return mangaView.chapters;
      case ChapterFilter.read:
        return mangaView.chapters.where(
              (chapter) => mangaView.getIsRead(chapter.id ?? -1),
        ).toList();
      case ChapterFilter.unread:
        return mangaView.chapters.where(
              (chapter) => !mangaView.getIsRead(chapter.id  ?? -1),
        ).toList();
    }
  }

  List<String> getGenres() {
    return state.mangaViews
        .expand((mangaView) => mangaView.manga.genres)
        .map((genre) => genre.name)
        .toSet()
        .toList();
  }

  int getUnreadChapters(String mangaTitle) {
    var manga = state.mangaViews.firstWhereOrNull((view) => view.manga.title == mangaTitle);
    if(manga != null) {
      return manga.chapters.length - manga.isReadByChapter.values.where((isRead) => isRead).length;
    }
    return 0;
  }

  int getReadChapters(String mangaTitle) {
    return state.mangaViews.firstWhereOrNull((view) => view.manga.title == mangaTitle)?.userManga?.isReadByChapter.values.where((isRead) => isRead).length ?? 0;
  }

  ReadingStatus getStatus(String mangaLink) {
    final mangaView = state.mangaViews.singleWhereOrNull((view) => view.manga.link == mangaLink);
    return mangaView?.userManga?.readingStatus ?? ReadingStatus.notReading;
  }

  List<MangaView> statusFilter(ReadingStatus status) {
    return state.mangaViews.where((mangaView) => mangaView.userManga?.readingStatus == status).toList();
  }

  List<MangaView> getFavorites() {
    return state.mangaViews.where((mangaView) => mangaView.userManga?.isFavorite ?? false).toList();
  }

  bool isFavorite(String mangaLink) {
    return state.mangaViews.any((view) => view.manga.link == mangaLink && (view.userManga?.isFavorite ?? false));
  }

  void updateBulkChapterReadStatus(String mangaLink, Set<int> chapterIds, {required bool isRead}) async {
    final userManga = state.mangaViews
        .firstWhereOrNull((view) => view.manga.link == mangaLink)
        ?.userManga;
    final newIsReadMap = Map<int, bool>.from(userManga?.isReadByChapter ?? {});
    for (final chapterId in chapterIds) {
      newIsReadMap[chapterId] = isRead;
    }
    await _userMangaRepository.saveUserManga(
        (userManga ?? UserManga(mangaLink: mangaLink)).copyWith(isReadByChapter: newIsReadMap)
    );
  }

  Future<void> updateReadingProgress({
    required String mangaLink,
    required int chapterId,
    required int lastPageRead,
  }) async {
    await _userMangaRepository.updateReadingProgress(
      mangaLink: mangaLink,
      chapterId: chapterId,
      lastPageRead: lastPageRead,
    );
  }

  void markAllBelowAsRead(String mangaLink, int chapterId) {
    final mangaToUpdate = state.mangaViews.firstWhere((view) => view.manga.link == mangaLink);
    final allChapters = mangaToUpdate.manga.chapters;
    final chapterIndex = allChapters.indexWhere((c) => c.id == chapterId);

    if (chapterIndex != -1) {
      final chaptersToMark = allChapters.sublist(chapterIndex);
      final chapterIdsToMark = chaptersToMark.map((c) => c.id ?? -1).toSet();

      updateBulkChapterReadStatus(mangaLink, chapterIdsToMark, isRead: true);
    }
  }
}