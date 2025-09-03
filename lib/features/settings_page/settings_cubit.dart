import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/data/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final savedState = await _repository.loadSettings();
      emit(savedState);
    } catch (e) {
      if(kDebugMode) {
        debugPrint('Failed to load settings: $e');
      }
    }
  }

  void _saveSettings() {
    _repository.saveSettings(state: state);
  }

  void toggleDarkMode(bool isEnabled) {
    emit(state.copyWith(isDarkMode: isEnabled));
    _saveSettings();
  }

  void toggleAutoBackup(bool isEnabled) {
    emit(state.copyWith(isAutoBackupEnabled: isEnabled));
    _saveSettings();
  }

  void setAutoBackupInterval(int interval) {
    emit(state.copyWith(autoBackupIntervalInHours: interval));
    _saveSettings();
  }

  void toggleDefaultDisplayMangaView(bool isListMode) {
    emit(state.copyWith(isListMode: isListMode));
  }

  void toggleDisplayUnreadChapters(bool isDisplayUnreadChapters) {
    emit(state.copyWith(isDisplayUnreadChapters: isDisplayUnreadChapters));
    _saveSettings();
  }

  void toggleSystemTheme(bool useSystemTheme) {
    emit(state.copyWith(useSystemTheme: useSystemTheme));
    _saveSettings();
  }

  void updateMangasPerPage(String value) {
    emit(state.copyWith(mangasPerPage: int.parse(value)));
    _saveSettings();
  }

  void updateMangasPerCategoryPage(String value) {
    emit(state.copyWith(mangasPerCategoryPage: int.parse(value)));
    _saveSettings();
  }

  void toggleDisplayCompletedStatus(bool isDisplayCompletedStatus) {
    emit(state.copyWith(isDisplayCompletedStatus: isDisplayCompletedStatus));
    _saveSettings();
  }

  void toggleDisplayReadingStatus(bool isDisplayReadingStatus) {
    emit(state.copyWith(isDisplayReadingStatus: isDisplayReadingStatus));
    _saveSettings();
  }

  void toggleDisplayFavoriteStatus(bool isDisplayFavoriteStatus) {
    emit(state.copyWith(isDisplayFavoriteStatus: isDisplayFavoriteStatus));
    _saveSettings();
  }

  void toggleAutoUpdate(bool isEnabled) {
    emit(state.copyWith(isAutoUpdateEnabled: isEnabled));
    _saveSettings();
  }

  void setAutoUpdateInterval(int interval) {
    emit(state.copyWith(autoUpdateIntervalInHours: interval));
    _saveSettings();
  }

  void toggleIsUpdateWifiOnly(bool isUpdateWifiOnly) {
    emit(state.copyWith(isUpdateWifiOnly: isUpdateWifiOnly));
    _saveSettings();
  }

  void toggleChapterDownloadWifiOnly(bool isChapterDownloadWifiOnly) {
    emit(state.copyWith(isChapterDownloadWifiOnly: isChapterDownloadWifiOnly));
    _saveSettings();
  }

  void toggleShowNotificationsAfterUpdate(bool showNotificationsAfterUpdate) {
    emit(state.copyWith(showNotificationsAfterUpdate: showNotificationsAfterUpdate));
    _saveSettings();
  }

  void toggleNotifyIfFavoriteMangaUpdated(bool notifyIfFavoriteMangaUpdated) {
    emit(state.copyWith(notifyIfFavoriteMangaUpdated: notifyIfFavoriteMangaUpdated));
    _saveSettings();
  }

  void toggleInfiniteScrollReadingPage(bool isInfiniteScrollReadingPage) {
    emit(state.copyWith(isInfiniteScrollReadingPage: isInfiniteScrollReadingPage));
    _saveSettings();
  }

  void toggleFadInTransition(bool useFadInTransition) {
    emit(state.copyWith(useFadInTransition: useFadInTransition));
    _saveSettings();
  }
}
