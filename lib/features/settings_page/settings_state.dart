import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final bool useSystemTheme;
  final bool isListMode;
  final bool isDisplayUnreadChapters;
  final bool isDisplayReadingStatus;
  final bool isDisplayCompletedStatus;
  final bool isChapterDownloadWifiOnly;
  final bool isDisplayFavoriteStatus;
  final bool isInfiniteScrollReadingPage;
  final int mangasPerPage;
  final int mangasPerCategoryPage;
  final bool isAutoBackupEnabled;
  final int autoBackupIntervalInHours;
  final bool isAutoUpdateEnabled;
  final int autoUpdateIntervalInHours;
  final bool isUpdateWifiOnly;
  final bool showNotificationsAfterUpdate;
  final bool notifyIfFavoriteMangaUpdated;
  final bool useFadInTransition;

  const SettingsState({
    this.isDarkMode = true,
    this.useSystemTheme = true,
    this.isListMode = true,
    this.isDisplayUnreadChapters = true,
    this.isDisplayReadingStatus = true,
    this.isDisplayCompletedStatus = true,
    this.isChapterDownloadWifiOnly = true,
    this.isInfiniteScrollReadingPage = true,
    this.isDisplayFavoriteStatus = false,
    this.mangasPerPage = 12,
    this.mangasPerCategoryPage = 12,
    this.isAutoBackupEnabled = false,
    this.autoBackupIntervalInHours = 24,
    this.isAutoUpdateEnabled = true,
    this.autoUpdateIntervalInHours = 12,
    this.isUpdateWifiOnly = true,
    this.showNotificationsAfterUpdate = true,
    this.notifyIfFavoriteMangaUpdated = true,
    this.useFadInTransition = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? useSystemTheme,
    bool? isListMode,
    bool? isDisplayUnreadChapters,
    bool? isDisplayReadingStatus,
    bool? isDisplayCompletedStatus,
    bool? isChapterDownloadWifiOnly,
    bool? isInfiniteScrollReadingPage,
    bool? isDisplayFavoriteStatus,
    int? mangasPerPage,
    int? mangasPerCategoryPage,
    bool? isAutoBackupEnabled,
    int? autoBackupIntervalInHours,
    bool? isAutoUpdateEnabled,
    int? autoUpdateIntervalInHours,
    bool? isUpdateWifiOnly,
    bool? showNotificationsAfterUpdate,
    bool? notifyIfFavoriteMangaUpdated,
    bool? useFadInTransition,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      isListMode: isListMode ?? this.isListMode,
      isDisplayUnreadChapters: isDisplayUnreadChapters ?? this.isDisplayUnreadChapters,
      isDisplayReadingStatus: isDisplayReadingStatus ?? this.isDisplayReadingStatus,
      isDisplayCompletedStatus: isDisplayCompletedStatus ?? this.isDisplayCompletedStatus,
      isChapterDownloadWifiOnly: isChapterDownloadWifiOnly ?? this.isChapterDownloadWifiOnly,
      isInfiniteScrollReadingPage: isInfiniteScrollReadingPage ?? this.isInfiniteScrollReadingPage,
      isDisplayFavoriteStatus: isDisplayFavoriteStatus ?? this.isDisplayFavoriteStatus,
      mangasPerPage: mangasPerPage ?? this.mangasPerPage,
      mangasPerCategoryPage : mangasPerCategoryPage ?? this.mangasPerCategoryPage,
      isAutoBackupEnabled: isAutoBackupEnabled ?? this.isAutoBackupEnabled,
      autoBackupIntervalInHours: autoBackupIntervalInHours ?? this.autoBackupIntervalInHours,
      isAutoUpdateEnabled: isAutoUpdateEnabled ?? this.isAutoUpdateEnabled,
      autoUpdateIntervalInHours: autoUpdateIntervalInHours ?? this.autoUpdateIntervalInHours,
      isUpdateWifiOnly: isUpdateWifiOnly ?? this.isUpdateWifiOnly,
      showNotificationsAfterUpdate: showNotificationsAfterUpdate ?? this.showNotificationsAfterUpdate,
      notifyIfFavoriteMangaUpdated: notifyIfFavoriteMangaUpdated ?? this.notifyIfFavoriteMangaUpdated,
      useFadInTransition : useFadInTransition ?? this.useFadInTransition,
    );
  }

  @override
  List<Object> get props => [isDarkMode,
    useSystemTheme, isListMode, isDisplayUnreadChapters,
    isDisplayReadingStatus, isDisplayCompletedStatus,
    isChapterDownloadWifiOnly, isInfiniteScrollReadingPage,
    isDisplayFavoriteStatus, mangasPerPage, mangasPerCategoryPage,
    isAutoBackupEnabled, autoBackupIntervalInHours,
    isAutoUpdateEnabled, autoUpdateIntervalInHours, isUpdateWifiOnly,
    showNotificationsAfterUpdate, notifyIfFavoriteMangaUpdated,
    useFadInTransition,
  ];
}
