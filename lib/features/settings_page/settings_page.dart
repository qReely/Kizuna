import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/widgets/section_header/section_header.dart';
import 'settings_cubit.dart';
import 'settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settingsCubit = context.read<SettingsCubit>();
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SectionHeader(title: 'Theme'),
              SwitchListTile(
                title: const Text('Use System Theme'),
                subtitle: const Text('Toggle between system theme and app theme'),
                value: state.useSystemTheme,
                onChanged: (bool value) {
                  settingsCubit.toggleSystemTheme(value);
                },
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark themes'),
                value: state.isDarkMode,
                onChanged: (bool value) {
                  if (!state.useSystemTheme) {
                    settingsCubit.toggleDarkMode(value);
                  }
                },
              ),
              SectionHeader(title: 'Display'),
              SwitchListTile(
                title: Text('Display on Launch: ${state.isListMode ? 'List' : 'Grid'}'),
                subtitle: const Text('Toggle between ListMode or GridMode'),
                value: state.isListMode,
                onChanged: (bool value) {
                  settingsCubit.toggleDefaultDisplayMangaView(value);
                },
              ),
              SectionHeader(title: 'Manga Card'),
              SwitchListTile(
                title: const Text('Unread Chapter'),
                subtitle: const Text('Display unread chapters on Manga Card'),
                value: state.isDisplayUnreadChapters,
                onChanged: (bool value) {
                  settingsCubit.toggleDisplayUnreadChapters(value);
                },
              ),
              SwitchListTile(
                title: const Text('Reading Status'),
                subtitle: const Text('Display reading status on Manga Card'),
                value: state.isDisplayReadingStatus,
                onChanged: (bool value) {
                  settingsCubit.toggleDisplayReadingStatus(value);
                },
              ),
              SwitchListTile(
                title: const Text('Completed Status'),
                subtitle: const Text('Display completed status on Manga Card'),
                value: state.isDisplayCompletedStatus,
                onChanged: (bool value) {
                  settingsCubit.toggleDisplayCompletedStatus(value);
                },
              ),
              SwitchListTile(
                title: const Text('Favorite Status'),
                subtitle: const Text('Display favorite status on Manga Card'),
                value: state.isDisplayFavoriteStatus,
                onChanged: (bool value) {
                  settingsCubit.toggleDisplayFavoriteStatus(value);
                },
              ),
              SectionHeader(title: 'Page Content'),
              ListTile(
                title: const Text('Mangas Per Page'),
                trailing: DropdownButton<String>(
                  value: state.mangasPerPage.toString(),
                  items: <String>['12', '18', '24', '30']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      settingsCubit.updateMangasPerPage(newValue);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Mangas Per Category Page'),
                trailing: DropdownButton<String>(
                  value: state.mangasPerCategoryPage.toString(),
                  items: <String>['12', '18', '24', '30']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      settingsCubit.updateMangasPerCategoryPage(newValue);
                    }
                  },
                ),
              ),
              SectionHeader(title: 'Animation'),
              SwitchListTile(
                title: const Text('Fade In Transition'),
                subtitle: const Text('Toggle Fade In Animation'),
                value: state.useFadInTransition,
                onChanged: (bool value) {
                  settingsCubit.toggleFadInTransition(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}