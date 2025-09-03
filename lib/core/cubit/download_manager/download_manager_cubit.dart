import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/enums/download_manga_sort_option.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/data/services/download_manager_service.dart';
import 'package:collection/collection.dart';

import 'download_manager_state.dart';


Future<double> _calculateChapterSizeInIsolate(List<String> paths) async {
  int sizeInBytes = 0;
  for (final path in paths) {
    final file = File(path);
    if (await file.exists()) {
      sizeInBytes += await file.length();
    }
  }
  return sizeInBytes / (1024 * 1024);
}

class DownloadManagerCubit extends Cubit<DownloadManagerState> {
  final UserMangaRepository _userMangaRepository;
  final DownloadManagerService _downloadManagerService;
  StreamSubscription? _mangaSubscription;


  DownloadManagerCubit(this._userMangaRepository, this._downloadManagerService)
      : super(
      const DownloadManagerState(downloadedMangas: [], isLoading: true)) {
    _init();
  }

  @override
  Future<void> close() {
    _mangaSubscription?.cancel();
    return super.close();
  }

  void _init() async {
    await loadDownloadedChapters();
    _mangaSubscription = _userMangaRepository.getCombinedMangaStream().listen(
          (updatedMangaViews) async {
        final downloadedMangas = updatedMangaViews.where((view) =>
        view.userManga?.downloadedImagePathsByChapter.isNotEmpty ?? false).map((
            view) => view.userManga!).toList();
        final totalSize = await _calculateTotalSize(downloadedMangas);
        emit(state.copyWith(
          downloadedMangas: downloadedMangas,
          totalDownloadedSize: totalSize,
        ));
        await loadDownloadedChapters();
      },
    );
  }

  Future<void> loadDownloadedChapters() async {
    print("State before: ${state.isLoading}");
    emit(state.copyWith(isLoading: true));
    try {
      final userMangas = await _userMangaRepository.getAllDownloadedUserManga();
      final downloadedMangaDetails = <DownloadedMangaView>[];

      for (final userManga in userMangas) {
        final manga = await _userMangaRepository.getManga(userManga.mangaLink);
        if (manga != null) {
          final size = await _calculateChapterSizeInIsolate(
            userManga.downloadedImagePathsByChapter.values.expand((element) => element).toList(),
          );
          downloadedMangaDetails.add(DownloadedMangaView(
            userManga: userManga,
            manga: manga,
            sizeInMB: size,
          ));
          await loadDownloadedChapterDetails(manga.link);
        }
      }

      final totalSize = downloadedMangaDetails.fold(0.0, (sum, view) => sum + view.sizeInMB);

      emit(state.copyWith(
        downloadedMangaDetails: downloadedMangaDetails,
        totalDownloadedSize: totalSize,
      ));
      print("State after: ${state.isLoading}");
      sort(state.sortOption, refresh: true);
      print("State after sort: ${state.isLoading}");
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load downloaded chapters: $e',
      ));
    }
  }

  void sort(SortOption option, {bool? isAscending, bool? refresh}) {
    final List<DownloadedMangaView> sortedList = List.from(state.downloadedMangaDetails);
    bool ascending = isAscending ?? state.isAscending;

    switch (option) {
      case SortOption.title:
        sortedList.sort((a, b) => a.manga.title.compareTo(b.manga.title));
        break;
      case SortOption.size:
        sortedList.sort((a, b) => a.sizeInMB.compareTo(b.sizeInMB));
        break;
      case SortOption.chapterCount:
        sortedList.sort((a, b) => a.userManga.downloadedImagePathsByChapter.length.compareTo(b.userManga.downloadedImagePathsByChapter.length));
        break;
    }

    if (!ascending) {
      sortedList.sort((a, b) => b.manga.title.compareTo(a.manga.title));

      switch (option) {
        case SortOption.title:
          sortedList.sort((a, b) => b.manga.title.compareTo(a.manga.title));
          break;
        case SortOption.size:
          sortedList.sort((a, b) => b.sizeInMB.compareTo(a.sizeInMB));
          break;
        case SortOption.chapterCount:
          sortedList.sort((a, b) => b.userManga.downloadedImagePathsByChapter.length.compareTo(a.userManga.downloadedImagePathsByChapter.length));
          break;
      }
    }

    emit(state.copyWith(
      isLoading: !(refresh ?? !state.isLoading) ,
      downloadedMangaDetails: sortedList,
      sortOption: option,
      isAscending: ascending,
    ));
  }

  Future<void> loadDownloadedChapterDetails(String mangaLink, {bool refresh = false}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userManga = await _userMangaRepository.getUserManga(mangaLink);
      final manga = await _userMangaRepository.getManga(mangaLink);
      if (userManga == null || manga == null || userManga.downloadedImagePathsByChapter.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      List<DownloadedChapterView> downloadedChapterDetails = List.from(state.downloadedChapterDetails);
      final downloadedChapterIds = userManga.downloadedImagePathsByChapter.keys.toList();
      final allChapters = manga.chapters;

      for (var chapterId in downloadedChapterIds) {
        final chapter = allChapters.firstWhereOrNull((c) => c.id == chapterId);
        if (chapter != null) {
          final filePaths = userManga.downloadedImagePathsByChapter[chapterId]!;
          final sizeInMB = await compute(_calculateChapterSizeInIsolate, filePaths);
          final isRead = userManga.isReadByChapter[chapterId] ?? false;
          if(downloadedChapterDetails.any((element) => element.chapter.id == chapter.id)) {
            downloadedChapterDetails.removeWhere((element) => element.chapter.id == chapter.id);
          }
          downloadedChapterDetails.add(DownloadedChapterView(
            mangaLink: mangaLink,
            chapter: chapter,
            isRead: isRead,
            sizeInMB: sizeInMB,
          ));
        }
      }
      emit(state.copyWith(
        isLoading: !refresh,
        downloadedChapterDetails: downloadedChapterDetails,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chapter details: $e',
      ));
    }
  }

  Future<double> _calculateTotalSize(List<UserManga> downloadedMangas) async {
    final List<String> paths = downloadedMangas
        .expand((manga) => manga.downloadedImagePathsByChapter.values)
        .expand((paths) => paths)
        .toList();

    if (paths.isEmpty) {
      return 0.0;
    }

    return await compute(_calculateChapterSizeInIsolate, paths);
  }

  Future<void> deleteAllChapters() async {
    try {
      emit(state.copyWith(isLoading: true));
      final downloadedMangas = await _userMangaRepository.getAllDownloadedUserManga();
      if (downloadedMangas.isEmpty) {
        await loadDownloadedChapters();
        return;
      }

      final List<String> filePaths = [];
      final List<String> mangaTitles = [];
      for (var manga in downloadedMangas) {
        filePaths.addAll(manga.downloadedImagePathsByChapter.values.expand((paths) => paths));
        mangaTitles.add( await _userMangaRepository.getMangaTitle(manga.mangaLink));
        manga.downloadedImagePathsByChapter.clear();
        await _userMangaRepository.saveUserManga(manga);
      }

      await _downloadManagerService.deleteAllDownloadedChapters(
        filePaths: filePaths,
        mangaTitles: mangaTitles,
      );

      await loadDownloadedChapters();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete all chapters: $e',
      ));
    }
  }

  Future<void> deleteReadChapters() async {
    try {
      emit(state.copyWith(isLoading: true));
      final downloadedMangas = await _userMangaRepository.getAllDownloadedUserManga();
      if (downloadedMangas.isEmpty) {
        await loadDownloadedChapters();
        return;
      }

      for (var manga in downloadedMangas) {
        final List<String> filePaths = [];
        final List<String> directoryPaths = [];
        final chaptersToDelete = <int>[];

        manga.downloadedImagePathsByChapter.forEach((chapterId, paths) {
          if (manga.isReadByChapter[chapterId] == true) {
            filePaths.addAll(paths);
            directoryPaths.add('mangas/${_userMangaRepository.getMangaTitle(manga.mangaLink)}/$chapterId');
            chaptersToDelete.add(chapterId);
          }
        });

        if (filePaths.isNotEmpty) {
          await _downloadManagerService.deleteReadDownloadedChapters(
            filePaths: filePaths,
            directoryPaths: directoryPaths,
          );
        }

        for (var chapterId in chaptersToDelete) {
          manga.downloadedImagePathsByChapter.remove(chapterId);
        }

        if (chaptersToDelete.isNotEmpty) {
          await _userMangaRepository.saveUserManga(manga);
        }
      }
      await loadDownloadedChapters();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete read chapters: $e',
      ));
    }
  }
  Future<void> deleteSingleDownloadedChapter(String mangaLink, int chapterId) async {
    try {
      final title = await _userMangaRepository.getMangaTitle(mangaLink);
      await _downloadManagerService.deleteSingleDownloadedChapter(
        mangaTitle: title, chapterId: chapterId,
      );
      await _userMangaRepository.deleteDownloadedChapter(mangaLink, chapterId);
      state.downloadedChapterDetails.removeWhere((chapter) => chapter.chapter.id == chapterId);
      await loadDownloadedChapterDetails(mangaLink, refresh: true);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete chapter: $e'));
    }
  }

  Future<void> deleteAllChaptersForManga(String mangaLink) async {
    try {
      emit(state.copyWith(isLoading: true));
      final userManga = await _userMangaRepository.getUserManga(mangaLink);
      if (userManga == null) {
        await loadDownloadedChapters();
        return;
      }

      final List<String> filePaths = userManga.downloadedImagePathsByChapter.values.expand((paths) => paths).toList();
      if(filePaths.isNotEmpty) {
        await _downloadManagerService.deleteAllChaptersForManga(
          mangaTitle: await _userMangaRepository.getMangaTitle(mangaLink),
        );
      }
      await _userMangaRepository.deleteDownloadedChapters(userManga.mangaLink);

      List<UserManga> downloadedMangas = List.from(state.downloadedMangas.where((manga) => manga.mangaLink != mangaLink));

      emit(state.copyWith(
        isLoading: false,
        totalDownloadedSize: await _calculateTotalSize(downloadedMangas),
        downloadedMangaDetails: List.from(state.downloadedMangaDetails.where((manga) => manga.manga.link != mangaLink)),
        downloadedMangas: downloadedMangas,
        downloadedChapterDetails: List.from(state.downloadedChapterDetails.where((chapter) => chapter.mangaLink != mangaLink)),
      ));
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete all chapters for manga: $e',
      ));
    }
  }

  Future<void> deleteReadChaptersForManga(String mangaLink) async {
    try {
      emit(state.copyWith(isLoading: true));
      final userManga = await _userMangaRepository.getUserManga(mangaLink);
      if (userManga == null) {
        await loadDownloadedChapters();
        return;
      }

      final List<String> chapterPaths = [];
      userManga.isReadByChapter.entries
          .where((entry) => entry.value)
          .forEach((entry) {
        if (userManga.downloadedImagePathsByChapter.containsKey(entry.key)) {
          chapterPaths.addAll(userManga.downloadedImagePathsByChapter[entry.key]!);
        }
      });

      if(chapterPaths.isNotEmpty) {
        await _downloadManagerService.deleteReadChaptersForManga(
          mangaTitle: await _userMangaRepository.getMangaTitle(mangaLink),
          chapterPaths: chapterPaths,
        );
      }

      userManga.isReadByChapter.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList()
          .forEach((key) {
        userManga.downloadedImagePathsByChapter.remove(key);
        state.downloadedChapterDetails.removeWhere((chapter) => chapter.chapter.id == key);
      });
      await _userMangaRepository.saveUserManga(userManga);
      await loadDownloadedChapters();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete read chapters for manga: $e',
      ));
    }
  }
}