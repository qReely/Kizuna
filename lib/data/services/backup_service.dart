import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:manga_reader_app/app/app_constants.dart';
import 'package:manga_reader_app/app/app_env.dart';
import 'package:manga_reader_app/data/repositories/settings_repository.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/data/services/notification_service.dart';
import 'package:manga_reader_app/hive/hive_registrar.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:manga_reader_app/data/repositories/backup_repository.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/models/mangas_model.dart';
import '../../core/models/user_manga_model.dart';
import 'manga_api_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (kDebugMode) {
        debugPrint("Workmanager task: $taskName is starting...");
      }

      await IsolatedHive.initFlutter();
      IsolatedHive.registerAdapters();
      NotificationService();
      final mangaBox = await IsolatedHive.openBox<Manga>(AppConstants.mangaBoxTitle);
      final userMangaBox = await IsolatedHive.openBox<UserManga>(AppConstants.userMangaBoxTitle);
      final settingsBox = await IsolatedHive.openBox<dynamic>(AppConstants.settingsBoxTitle);


      final settings = await SettingsRepository(settingsBox).loadSettings();


      if (taskName == AppConstants.autoBackupTask) {
        final backupRepository = BackupRepository(mangaBox, userMangaBox);
        final directory = await getDownloadsDirectory();
        final directoryPath = directory?.path;

        if (directoryPath != null) {
          await backupRepository.autoBackup(directoryPath);
          return true;
        } else {
          if(kDebugMode) {
            debugPrint("Could not get downloads directory path.");
          }
          return false;
        }
      }
      else if(taskName == AppConstants.latestUpdatesFetchTask || taskName == AppConstants.updateMangaNow) {
        final repository = await Supabase.initialize(
          url: Env.supabaseUrl,
          anonKey: Env.supabaseAnonKey,
        );
        final mangaApiService = MangaApiService(repository.client);
        final mangaRepository = UserMangaRepository(userMangaBox, mangaBox, mangaApiService);
        await mangaRepository.fetchAndStoreAllMangas(settings);
        return true;
      }
      return false;
    } catch (e, stacktrace) {
      if (kDebugMode) {
        debugPrint("Error in Workmanager task: $e");
        debugPrint(stacktrace.toString());
      }
      return false;
    }
  });
}
