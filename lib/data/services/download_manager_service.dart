import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> _deleteFilesInIsolate(List<String> filePaths) async {
  for (final path in filePaths) {
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        if(kDebugMode) {
          debugPrint('Error deleting file $path: $e');
        }
      }
    }
  }
}

Future<void> _deleteDirectoryIfEmptyInIsolate(String path) async {
  final directory = Directory(path);
  if (await directory.exists()) {
    if (await directory.list().isEmpty) {
      try {
        await directory.delete();
      } catch (e) {
        if(kDebugMode) {
          debugPrint('Error deleting empty directory $path: $e');
        }
      }
    }
  }
}

class DownloadManagerService {

  Future<void> deleteAllDownloadedChapters({
    required List<String> filePaths,
    required List<String> mangaTitles,
  }) async {
    await compute(_deleteFilesInIsolate, filePaths);
    final directory = await getApplicationDocumentsDirectory();
    final List<String> directoryPaths = mangaTitles.map((title) => '${directory.path}/mangas/$title').toList();
    await Future.wait(directoryPaths.map((path) => compute(_deleteDirectoryIfEmptyInIsolate, path)));
  }

  Future<void> deleteReadDownloadedChapters({
    required List<String> filePaths,
    required List<String> directoryPaths,
  }) async {
    await compute(_deleteFilesInIsolate, filePaths);
    await Future.wait(directoryPaths.map((path) => compute(_deleteDirectoryIfEmptyInIsolate, path)));
  }

  Future<void> deleteAllChaptersForManga({
    required String mangaTitle,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final mangaDirectory = Directory('${directory.path}/mangas/$mangaTitle');
    if (await mangaDirectory.exists()) {
      await mangaDirectory.delete(recursive: true);
    }
  }

  Future<void> deleteReadChaptersForManga({
    required String mangaTitle,
    required List<String> chapterPaths,
  }) async {
    await compute(_deleteFilesInIsolate, chapterPaths);
    await Future.wait(chapterPaths.map((path) {
      final chapterDirectory = path.substring(0, path.lastIndexOf('/'));
      return compute(_deleteDirectoryIfEmptyInIsolate, chapterDirectory);
    }));
  }

  Future<void> deleteSingleDownloadedChapter({
    required String mangaTitle,
    required int chapterId,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final chapterDirectoryPath = '${directory.path}/mangas/$mangaTitle/$chapterId';
    final chapterDirectory = Directory(chapterDirectoryPath);

    if (await chapterDirectory.exists()) {
      await chapterDirectory.delete(recursive: true);
    }
  }
}