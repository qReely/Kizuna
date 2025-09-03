import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:manga_reader_app/app/app_constants.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:path_provider/path_provider.dart';

Map<String, dynamic> _convertMapKeysToString(Map<dynamic, dynamic> original) {
  final newMap = <String, dynamic>{};
  original.forEach((key, value) {
    final newKey = key.toString();
    if (value is Map) {
      newMap[newKey] = _convertMapKeysToString(value);
    } else if (value is List) {
      newMap[newKey] = value.map((item) {
        if (item is Map) {
          return _convertMapKeysToString(item);
        }
        return item;
      }).toList();
    } else {
      newMap[newKey] = value;
    }
  });
  return newMap;
}

class BackupData {
  final Map<String, dynamic> data;
  final String path;

  BackupData(this.data, this.path);
}

Future<void> _createBackupInIsolate(BackupData backupData) async {
  try {
    final backupDir = Directory(backupData.path);
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    // TODO - Delete old Backups
    // await _deleteOldBackups(backupData.path);
    final filePath = '${backupData.path}/manga_reader_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File(filePath);
    await file.writeAsString(jsonEncode(backupData.data));
    if(kDebugMode) {
      debugPrint('Backup created successfully at $filePath');
    }
  } catch (e) {
    if(kDebugMode) {
      debugPrint('Error creating backup: $e');
    }
  }
}

class BackupRepository {
  final IsolatedBox<Manga> mangaBox;
  final IsolatedBox<UserManga> userMangaBox;

  BackupRepository(this.mangaBox, this.userMangaBox);

  Future<void> createBackup(String directoryPath) async {
    try {
      final Map<String, dynamic> userMangaData = {};
      for (var key in (await userMangaBox.keys)) {
        final userManga = (await userMangaBox.get(key)) as UserManga;
        userMangaData[key.toString()] = userManga.toJson();
      }

      final Map<String, dynamic> mangaData = {};
      for (var key in (await mangaBox.keys)) {
        final manga = (await mangaBox.get(key)) as Manga;
        mangaData[key.toString()] = manga.toJson();
      }

      final Map<String, dynamic> backupData = {
        AppConstants.backupMangaTitle: _convertMapKeysToString(mangaData),
        AppConstants.backupUserMangaTitle: _convertMapKeysToString(userMangaData),
      };

      await compute(
        _createBackupInIsolate,
        BackupData(backupData, directoryPath),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating backup: $e');
      }
      rethrow;
    }
  }

  Future<void> loadBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      final Map<String, dynamic> mangaData = backupData[AppConstants.backupMangaTitle];
      final Map<String, dynamic> userMangaData = backupData[AppConstants.backupUserMangaTitle];

      await mangaBox.clear();
      await userMangaBox.clear();

      final mangasToLoad = mangaData.values
          .map((e) => Manga.fromJson(_convertMapKeysToString(e as Map)))
          .toList();
      for (var manga in mangasToLoad) {
        await mangaBox.put(manga.link, manga);
      }

      final userMangasToLoad = userMangaData.values
          .map((e) => UserManga.fromJson(_convertMapKeysToString(e as Map)))
          .toList();
      for (var userManga in userMangasToLoad) {
        await userMangaBox.put(userManga.mangaLink, userManga);
      }

      await _verifyDownloadedFiles();
    } catch (e) {
      if(kDebugMode) {
        debugPrint("Exception loading backup: $e");
      }
      rethrow;
    }
  }

  Future<File?> getLastBackupFile() async {
    final backupDirectoryPath = (await getDownloadsDirectory())?.path;
    if (backupDirectoryPath == null) {
      return null;
    }
    final backupDir = Directory(backupDirectoryPath);
    if (!await backupDir.exists()) {
      return null;
    }
    final files = backupDir.listSync().whereType<File>().where((file) {
      return file.path.endsWith('.json') &&
          file.path.split('/').last.startsWith('manga_reader_backup_');
    }).toList();

    if (files.isEmpty) {
      return null;
    }
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.first;
  }

  String? parseTimestampFromFilename(String filePath) {
    final filename = filePath.split('/').last;
    final parts = filename.split('manga_reader_backup_');
    if (parts.length >= 2) {
      final timestampPart = parts[1].replaceAll('.json', '');
      final timestampParts = timestampPart.split('T');
      if (timestampParts.length == 2) {
        final datePart = timestampParts[0];
        final timePart = timestampParts[1];

        final correctedTimestamp = '${datePart}T${timePart.replaceAll('-', ':')}';

        try {
          final dateTime = DateTime.parse(correctedTimestamp);
          final formattedDate = DateFormat('dd.MM.yy HH:mm:ss').format(dateTime);
          return formattedDate;
        } catch (e) {
          if(kDebugMode) {
            debugPrint('Error parsing date: $e');
          }
          return null;
        }
      }
    }
    return null;
  }

  Future<void> _verifyDownloadedFiles() async {
    final userMangaKeys = (await userMangaBox.keys).toList();
    for (var key in userMangaKeys) {
      final userManga = await userMangaBox.get(key);
      if (userManga == null) continue;

      final chaptersToDelete = <int>{};
      final newImagePaths = <int, List<String>>{};

      for (var chapterEntry in userManga.downloadedImagePathsByChapter.entries) {
        final chapterNumber = chapterEntry.key;
        final paths = chapterEntry.value;
        final validPaths = <String>[];

        for (var path in paths) {
          final file = File(path);
          if (await file.exists()) {
            validPaths.add(path);
          } else {
            if(kDebugMode) {
              debugPrint('File not found: $path');
            }
          }
        }

        if (validPaths.isEmpty) {
          chaptersToDelete.add(chapterNumber);
        } else {
          newImagePaths[chapterNumber] = validPaths;
        }
      }

      if (chaptersToDelete.isNotEmpty ||
          !mapEquals(userManga.downloadedImagePathsByChapter, newImagePaths)) {
        userManga.downloadedImagePathsByChapter = newImagePaths;
        userManga.isReadByChapter.removeWhere((key, value) => chaptersToDelete.contains(key));
        await userMangaBox.put(key, userManga);
      }
    }
  }

  Future<void> clearStorage() async {
    try {
      await userMangaBox.clear();
      await mangaBox.clear();
      if(kDebugMode) debugPrint("Storage cleared successfully.");
    } catch (e) {
      throw Exception('Error clearing storage: $e');
    }
  }

  Future<void> autoBackup(String directoryPath) async {
    try {
      final Map<String, dynamic> backupData = {
        'manga': await mangaBox.toMap(),
        'user_manga': await userMangaBox.toMap(),
      };
      await compute(_createBackupInIsolate, BackupData(backupData, directoryPath));
    } catch (e) {
      if(kDebugMode) {
        debugPrint('Error during auto-backup: $e');
      }
    }
  }
}