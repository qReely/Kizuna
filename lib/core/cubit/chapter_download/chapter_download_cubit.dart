import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:manga_reader_app/core/cubit/chapter_download/chapter_download_state.dart';
import 'package:manga_reader_app/core/enums/chapter_download_status.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/data/services/download_manager_service.dart';
import 'package:manga_reader_app/data/services/manga_api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChapterDownloadCubit extends Cubit<ChapterDownloadState> {
  final UserMangaRepository _userMangaRepository;
  final DownloadManagerService _downloadManagerService;

  final Map<int, List<String>> _downloadQueue = {};
  Completer<void>? _currentDownloadCompleter;

  ChapterDownloadCubit(
      this._userMangaRepository,
      this._downloadManagerService,
      ) : super(const ChapterDownloadState(status: ChapterDownloadStatus.initial));

  bool isInQueue(int chapterId) => _downloadQueue.containsKey(chapterId);

  void cancelDownload(int chapterId) {
    if (_downloadQueue.containsKey(chapterId)) {
      _downloadQueue.remove(chapterId);
      emit(state.copyWith(
        status: ChapterDownloadStatus.canceled,
        chapterId: chapterId,
        message: 'Download for chapter $chapterId has been canceled.',
      ));
    }
  }

  Future<void> downloadChapter({
    required String mangaLink,
    required int chapterId,
  }) async {
    if (isInQueue(chapterId)) return;

    _downloadQueue[chapterId] = await MangaApiService(Supabase.instance.client).getChapterImages(chapterId);
    emit(state.copyWith(
      status: ChapterDownloadStatus.inQueue,
      chapterId: chapterId,
      message: 'In Queue',
    ));

    await _processQueue(mangaLink);
  }

  Future<void> _processQueue(String mangaLink) async {
    if (_currentDownloadCompleter != null && !_currentDownloadCompleter!.isCompleted) {
      return;
    }

    _currentDownloadCompleter = Completer<void>();
    while (_downloadQueue.isNotEmpty) {
      final chapterId = _downloadQueue.keys.first;
      final currentImageUrls = _downloadQueue[chapterId]!;

      emit(state.copyWith(
        status: ChapterDownloadStatus.inProgress,
        progress: 0.0,
        chapterId: chapterId,
        message: 'Starting download...',
      ));

      try {
        final directory = await getApplicationDocumentsDirectory();
        final mangaTitle = await _userMangaRepository.getMangaTitle(mangaLink);
        final chapterDirectoryPath = '${directory.path}/mangas/$mangaTitle/$chapterId';

        final tempFiles = [];
        int successfullyDownloaded = 0;

        for (int i = 0; i < currentImageUrls.length; i++) {
          if (!isInQueue(chapterId)) {
            break;
          }
          final url = currentImageUrls[i];
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final fileName = url.split('/').last;
            tempFiles.add({'$chapterDirectoryPath/$fileName': response.bodyBytes});

            successfullyDownloaded++;

            final progress = successfullyDownloaded / currentImageUrls.length;
            emit(state.copyWith(
              status: ChapterDownloadStatus.inProgress,
              progress: progress,
              chapterId: chapterId,
            ));
          } else {
            throw Exception('Failed to download $url: ${response.statusCode}');
          }
        }

        if (successfullyDownloaded == currentImageUrls.length) {
          if (!Directory(chapterDirectoryPath).existsSync()) {
            Directory(chapterDirectoryPath).createSync(recursive: true);
          }

          final savedPaths = <String>[];
          for (final entry in tempFiles) {
            final filePath = entry.keys.first;
            final bytes = entry.values.first;
            final file = File(filePath);
            await file.writeAsBytes(bytes);
            savedPaths.add(filePath);
          }

          await _userMangaRepository.updateDownloadedChapterPaths(
            mangaLink: mangaLink,
            chapterId: chapterId,
            downloadedPaths: savedPaths,
          );
          emit(state.copyWith(
            status: ChapterDownloadStatus.success,
            chapterId: chapterId,
            message: 'Chapter downloaded successfully!',
          ));
        } else {
          emit(state.copyWith(
            status: ChapterDownloadStatus.failure,
            chapterId: chapterId,
            error: 'Not all images could be downloaded',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: ChapterDownloadStatus.failure,
          chapterId: chapterId,
          error: 'An error occurred during download: $e',
        ));
      }

      _downloadQueue.remove(chapterId);
    }
    _currentDownloadCompleter!.complete();
  }


  Future<void> deleteChapter(String mangaLink, int chapterId) async {
    try {
      final pathsToDelete = await _userMangaRepository.downloadedChapterImages(mangaLink, chapterId);
      if (kDebugMode) {
        debugPrint(pathsToDelete.toString());
      }
      final mangaTitle = await _userMangaRepository.getMangaTitle(mangaLink);
      if (kDebugMode) {
        debugPrint(mangaTitle);
      }
      if (pathsToDelete.isNotEmpty) {
        await _downloadManagerService.deleteSingleDownloadedChapter(
          mangaTitle: mangaTitle,
          chapterId: chapterId,
        );
        await _userMangaRepository.updateDownloadedChapterPaths(
          mangaLink: mangaLink,
          chapterId: chapterId,
          downloadedPaths: [],
        );
        emit(state.copyWith(
          status: ChapterDownloadStatus.success,
          chapterId: chapterId,
          message: 'Chapter deleted successfully.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChapterDownloadStatus.failure,
        chapterId: chapterId,
        error: 'Failed to delete chapter: $e',
      ));
    }
  }
}