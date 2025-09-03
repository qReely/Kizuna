import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/data/services/manga_api_service.dart';
import 'package:manga_reader_app/features/reading_page/reading_page_state.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReadingPageCubit extends Cubit<ReadingPageState> {
  final UserMangaRepository _userMangaRepository;
  final MangaView _mangaView;
  final List<Chapter> _chapters;
  int _currentChapterIndex;
  late ItemScrollController itemScrollController;

  ReadingPageCubit(this._userMangaRepository, this._mangaView, int initialChapterId, int initialLastPageRead)
      : _chapters = _mangaView.chapters,
        _currentChapterIndex = _mangaView.chapters.indexWhere((c) => c.id == initialChapterId),
        super(ReadingPageLoading()) {
    fetchImages(initialChapterId, initialLastPageRead);
    itemScrollController = ItemScrollController();
  }

  int get currentChapterIndex => _currentChapterIndex;

  void updateCurrentPageIndex(int newPageIndex) {
    if (state is ReadingPageLoaded) {
      final loadedState = state as ReadingPageLoaded;
      emit(loadedState.copyWith(lastPageIndex: newPageIndex));
    }
  }

  Future<void> fetchImages(int chapterId, int initialLastPageRead) async {
    try {
      emit(ReadingPageLoading());
      List<String> images;
      final downloaded = await _userMangaRepository.downloadedChapterImages(_mangaView.link, chapterId);
      if(downloaded.isNotEmpty) {
        images = downloaded;
      }
      else {
        images = await MangaApiService(Supabase.instance.client).getChapterImages(chapterId);
      }

      if (images.isEmpty) {
        emit(ReadingPageError(message: 'No images found for this chapter.'));
        return;
      }

      emit(ReadingPageLoaded(
        imageUrls: images,
        lastPageIndex: initialLastPageRead,
        currentChapterId: chapterId,
      ));
    } catch (e) {
      emit(ReadingPageError(message: 'Failed to load chapter: $e'));
    }
  }

  bool getBookmarkStatus(int chapterId) {
    final isBookmarked = _mangaView.userManga?.chapterBookmarks?[chapterId] ?? false;
    print('ReadingPageCubit: getBookmarkStatus for chapter $chapterId: $isBookmarked');
    return isBookmarked;
  }

  Future<void> loadNextChapterByIndex(int nextChapterIndex) async {
    if (state is! ReadingPageLoaded) {
      return;
    }

    final loadedState = state as ReadingPageLoaded;

    try {
      emit(ReadingPageLoading());
      await _userMangaRepository.updateReadingProgress(
        mangaLink: _mangaView.link,
        chapterId: loadedState.currentChapterId,
        lastPageRead: loadedState.lastPageIndex
      );

      final nextChapterId = _chapters[nextChapterIndex].id;
      List<String> nextChapterImages;

      if(await _userMangaRepository.isChapterDownloaded(_mangaView.manga.link, nextChapterId  ?? -1)) {
        nextChapterImages = await _userMangaRepository.downloadedChapterImages(_mangaView.manga.link, nextChapterId  ?? -1);
      } else {
        nextChapterImages = await MangaApiService(Supabase.instance.client).getChapterImages(nextChapterId  ?? -1);
      }

      if (nextChapterImages.isEmpty) {
        emit(loadedState);
        return;
      }

      _currentChapterIndex = nextChapterIndex;
      emit(ReadingPageLoaded(
        imageUrls: nextChapterImages,
        lastPageIndex: 0,
        currentChapterId: nextChapterId  ?? -1,
      ));
    } catch (e) {
      emit(ReadingPageError(message: 'Failed to load next chapter: $e'));
    }
  }

  Future<void> loadNextChapter({int? nextChapter}) async {
    if (nextChapter == null && (state is! ReadingPageLoaded || _currentChapterIndex - 1 < 0)) {
      return;
    }

    final loadedState = state as ReadingPageLoaded;
    final nextChapterIndex = nextChapter ?? _currentChapterIndex - 1;

    try {
      emit(ReadingPageLoading());
      await _userMangaRepository.updateReadingProgress(
        mangaLink: _mangaView.link,
        chapterId: loadedState.currentChapterId,
        lastPageRead: loadedState.imageUrls.length - 1,
        isRead: true,
      );

      final nextChapterId = _chapters[nextChapterIndex].id;
      List<String> nextChapterImages;

      if(await _userMangaRepository.isChapterDownloaded(_mangaView.manga.link, nextChapterId  ?? -1)) {
        nextChapterImages = await _userMangaRepository.downloadedChapterImages(_mangaView.manga.link, nextChapterId  ?? -1);
      } else {
        nextChapterImages = await MangaApiService(Supabase.instance.client).getChapterImages(nextChapterId  ?? -1);
      }

      if (nextChapterImages.isEmpty) {
        emit(loadedState);
        return;
      }

      _currentChapterIndex = nextChapterIndex;
      emit(ReadingPageLoaded(
        imageUrls: nextChapterImages,
        lastPageIndex: 0,
        currentChapterId: nextChapterId  ?? -1,
      ));
    } catch (e) {
      emit(ReadingPageError(message: 'Failed to load next chapter: $e'));
    }
  }

  Future<void> saveReadingProgress({
    required String mangaLink,
  }) async {
    if (state is ReadingPageLoaded) {
      final loadedState = state as ReadingPageLoaded;
      try {
        await _userMangaRepository.updateReadingProgress(
          mangaLink: mangaLink,
          chapterId: loadedState.currentChapterId,
          lastPageRead: loadedState.lastPageIndex,
        );
        debugPrint('Reading progress saved successfully for ${loadedState.currentChapterId}');
      } catch (e) {
        debugPrint('Error saving reading progress: $e');
      }
    }
  }
}
