import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:manga_reader_app/app/app_constants.dart';
import 'package:manga_reader_app/app/app_env.dart';
import 'package:manga_reader_app/app/app_themes.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';
import 'package:manga_reader_app/core/widgets/app_provider/app_provider.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/data/repositories/settings_repository.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/data/services/backup_service.dart';
import 'package:manga_reader_app/data/services/download_manager_service.dart';
import 'package:manga_reader_app/data/services/manga_api_service.dart';
import 'package:manga_reader_app/features/manga_loader.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';
import 'package:manga_reader_app/hive/hive_registrar.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'data/services/notification_service.dart';
import 'features/settings_page/settings_cubit.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> _initializeAppDependencies() async {
  var dir = await getApplicationDocumentsDirectory();
  await IsolatedHive.initFlutter();
  IsolatedHive..init(dir.path)..registerAdapters();

  await NotificationService().init();

  final repository = await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  Workmanager().initialize(callbackDispatcher);

  final mangaBox = await IsolatedHive.openBox<Manga>(AppConstants.mangaBoxTitle);
  final userMangaBox = await IsolatedHive.openBox<UserManga>(AppConstants.userMangaBoxTitle);
  final settingsBox = await IsolatedHive.openBox<dynamic>(AppConstants.settingsBoxTitle);
  final appStateBox = await IsolatedHive.openBox(AppConstants.appSateBoxTitle);
  final settingsRepository = SettingsRepository(settingsBox)..loadSettings();
  final mangaApiService = MangaApiService(repository.client);
  final userMangaRepository = UserMangaRepository(userMangaBox, mangaBox, mangaApiService);
  final downloadManagerService = DownloadManagerService();

  final isFirstLaunch = await appStateBox.get('isFirstLaunch', defaultValue: true);
  if (isFirstLaunch) {
    await userMangaRepository.fetchAndStoreAllMangas(await settingsRepository.loadSettings());
    await appStateBox.put('isFirstLaunch', false);
  }
  final rootIsolateToken = RootIsolateToken.instance!;

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    AppProvider(
      userMangaRepository: userMangaRepository,
      settingsRepository: settingsRepository,
      rootIsolateToken: rootIsolateToken,
      mangaBox: mangaBox,
      userMangaBox: userMangaBox,
      downloadManagerService: downloadManagerService,
      mangaApiService: mangaApiService,
      child: const MyApp(),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeAppDependencies();
  GestureBinding.instance.resamplingEnabled = true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
      builder: (context, mangaState) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Kizuna',
              darkTheme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Roboto',
                primarySwatch: AppColors.primaryColorDark,
                brightness: Brightness.dark,
                pageTransitionsTheme: context.read<SettingsCubit>().state.useFadInTransition ? PageTransitionsTheme(
                  builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
                    TargetPlatform.values,
                    value: (_) => const FadeForwardsPageTransitionsBuilder(),
                  ),
                ) : null,
              ),
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Roboto',
                primarySwatch: AppColors.primaryColorLight,
                brightness: Brightness.light,
                pageTransitionsTheme: context.read<SettingsCubit>().state.useFadInTransition ? PageTransitionsTheme(
                  builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
                    TargetPlatform.values,
                    value: (_) => const FadeForwardsPageTransitionsBuilder(),
                  ),
                ) : null,
              ),
              themeMode: context.watch<SettingsCubit>().state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: mangaState.isLoading ?
              const Scaffold(
                body: LoadingAnimation(text: "Loading Manga",),
              )
                  : MangaLoader(),
            );
          }
        );
      },
    );
  }
}