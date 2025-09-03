import 'package:hive_ce/hive.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';

class SettingsRepository {
  final IsolatedBox<dynamic> _settingsBox;

  SettingsRepository(this._settingsBox);

  Future<void> saveSettings({required SettingsState state}) async {
    await _settingsBox.put('isDarkMode', state.isDarkMode);
    await _settingsBox.put('useSystemTheme', state.useSystemTheme);
    await _settingsBox.put('isListMode', state.isListMode);
    await _settingsBox.put('isDisplayUnreadChapters', state.isDisplayUnreadChapters);
    await _settingsBox.put('isDisplayReadingStatus', state.isDisplayReadingStatus);
    await _settingsBox.put('isDisplayCompletedStatus', state.isDisplayCompletedStatus);
    await _settingsBox.put('isDisplayFavoriteStatus', state.isDisplayFavoriteStatus);
    await _settingsBox.put('mangasPerPage', state.mangasPerPage);
    await _settingsBox.put('mangasPerCategoryPage', state.mangasPerCategoryPage);
    await _settingsBox.put('isAutoBackupEnabled', state.isAutoBackupEnabled);
    await _settingsBox.put('autoBackupIntervalInHours', state.autoBackupIntervalInHours);
    await _settingsBox.put('isAutoUpdateEnabled', state.isAutoUpdateEnabled);
    await _settingsBox.put('showNotificationsAfterUpdate', state.showNotificationsAfterUpdate);
    await _settingsBox.put('notifyIfFavoriteMangaUpdated', state.notifyIfFavoriteMangaUpdated);
    await _settingsBox.put('isChapterDownloadWifiOnly', state.isChapterDownloadWifiOnly);
    await _settingsBox.put('isInfiniteScrollReadingPage', state.isInfiniteScrollReadingPage);
    await _settingsBox.put('autoUpdateIntervalInHours', state.autoUpdateIntervalInHours);
    await _settingsBox.put('isUpdateWifiOnly', state.isUpdateWifiOnly);
    await _settingsBox.put('useFadInTransition', state.useFadInTransition);
  }

  Future<SettingsState> loadSettings() async {
    return SettingsState().copyWith(
      isDarkMode: await _settingsBox.get('isDarkMode'),
      useSystemTheme: await _settingsBox.get('useSystemTheme'),
      isListMode: await _settingsBox.get('isListMode'),
      isDisplayUnreadChapters: await _settingsBox.get('isDisplayUnreadChapters'),
      isDisplayReadingStatus: await _settingsBox.get('isDisplayReadingStatus'),
      isDisplayCompletedStatus: await _settingsBox.get('isDisplayCompletedStatus'),
      isDisplayFavoriteStatus: await _settingsBox.get('isDisplayFavoriteStatus'),
      mangasPerPage: await _settingsBox.get('mangasPerPage'),
      mangasPerCategoryPage: await _settingsBox.get('mangasPerCategoryPage'),
      isAutoBackupEnabled: await _settingsBox.get('isAutoBackupEnabled'),
      autoBackupIntervalInHours: await _settingsBox.get('autoBackupIntervalInHours'),
      isAutoUpdateEnabled: await _settingsBox.get('isAutoUpdateEnabled'),
      showNotificationsAfterUpdate: await _settingsBox.get('showNotificationsAfterUpdate'),
      notifyIfFavoriteMangaUpdated: await _settingsBox.get('notifyIfFavoriteMangaUpdated'),
      isChapterDownloadWifiOnly: await _settingsBox.get('isChapterDownloadWifiOnly'),
      isInfiniteScrollReadingPage: await _settingsBox.get('isInfiniteScrollReadingPage'),
      autoUpdateIntervalInHours: await _settingsBox.get('autoUpdateIntervalInHours'),
      isUpdateWifiOnly: await _settingsBox.get('isUpdateWifiOnly'),
      useFadInTransition: await _settingsBox.get('useFadInTransition'),
    );
  }
}