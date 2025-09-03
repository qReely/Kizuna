import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:manga_reader_app/app/app_constants.dart';
import 'package:manga_reader_app/core/cubit/backup_cubit/backup_cubit.dart';
import 'package:manga_reader_app/core/cubit/chapter_download/chapter_download_cubit.dart';
import 'package:manga_reader_app/core/cubit/download_manager/download_manager_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:manga_reader_app/data/repositories/backup_repository.dart';
import 'package:manga_reader_app/data/repositories/settings_repository.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/data/services/download_manager_service.dart';
import 'package:manga_reader_app/data/services/manga_api_service.dart';
import 'package:manga_reader_app/features/home_page/bottom_nav_cubit.dart';
import 'package:manga_reader_app/features/manga_chapters/manga_chapter_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

class AppProvider extends StatelessWidget {
  final Widget child;
  final UserMangaRepository userMangaRepository;
  final DownloadManagerService downloadManagerService;
  final MangaApiService mangaApiService;
  final SettingsRepository settingsRepository;
  final RootIsolateToken rootIsolateToken;
  final IsolatedBox<Manga> mangaBox;
  final IsolatedBox<UserManga> userMangaBox;

  const AppProvider({
    super.key,
    required this.child,
    required this.downloadManagerService,
    required this.userMangaRepository,
    required this.settingsRepository,
    required this.rootIsolateToken,
    required this.mangaBox,
    required this.userMangaBox,
    required this.mangaApiService,
  });

  @override
  Widget build(BuildContext context) {
    final settingsCubit = SettingsCubit(settingsRepository);
    final chapterDownloadCubit = ChapterDownloadCubit(userMangaRepository, downloadManagerService);

    settingsCubit.stream.listen((settingsState) {
      if (settingsState.isAutoBackupEnabled) {
        Workmanager().registerPeriodicTask(
          AppConstants.autoBackupTask,
          AppConstants.autoBackupTask,
          initialDelay: Duration(hours: settingsState.autoBackupIntervalInHours),
          constraints: Constraints(
            requiresStorageNotLow: true,
            requiresBatteryNotLow: true,
            networkType: NetworkType.connected,
          ),
        );
      } else {
        Workmanager().cancelByUniqueName(AppConstants.autoBackupTask);
      }

      if (settingsState.isAutoUpdateEnabled) {
        Workmanager().registerPeriodicTask(
          AppConstants.latestUpdatesFetchTask,
          AppConstants.latestUpdatesFetchTask,
          frequency: Duration(hours: settingsState.autoUpdateIntervalInHours),
          constraints: Constraints(
            requiresStorageNotLow: true,
            requiresBatteryNotLow: true,
            networkType: NetworkType.connected,
          ),
        );
      } else {
        Workmanager().cancelByUniqueName(AppConstants.latestUpdatesFetchTask);
      }
    });

    return MultiBlocProvider(
      providers: [
        Provider<UserMangaRepository>(
          create: (_) => userMangaRepository,
        ),
        Provider<BackupRepository>(
          create: (_) => BackupRepository(mangaBox, userMangaBox),
        ),
        Provider<DownloadManagerService>(
          create: (_) => downloadManagerService,
        ),
        Provider<MangaApiService>(
          create: (_) => mangaApiService,
        ),
        Provider<SettingsRepository>(
          create: (_) => settingsRepository,
        ),
        BlocProvider(create: (_) => MangaLibraryCubit(userMangaRepository, settingsCubit.state.isListMode)..loadManga()),
        BlocProvider(create: (_) => ChapterCubit([])),
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => chapterDownloadCubit),
        BlocProvider(create: (_) => settingsCubit),
        BlocProvider(create: (_) => DownloadManagerCubit(userMangaRepository, downloadManagerService)),
        BlocProvider(create: (_) => BackupCubit(BackupRepository(mangaBox, userMangaBox), rootIsolateToken)),
      ],
      child: child,
    );
  }
}