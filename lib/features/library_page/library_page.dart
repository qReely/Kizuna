import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/section_header/section_header.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryUpdatesPage extends StatelessWidget {
  const LibraryUpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
        builder: (context, state) {
          return context.read<MangaLibraryCubit>().state.isLoading ? const LoadingAnimation(text: "Checking for updates") : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final settingsCubit = context.read<SettingsCubit>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Auto-Updates'),
                      SwitchListTile(
                        title: const Text('Auto Library Update'),
                        subtitle: const Text('Update manga library in background'),
                        value: state.isAutoUpdateEnabled,
                        onChanged: (bool value) {
                          settingsCubit.toggleAutoUpdate(value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Wifi-only updates'),
                        subtitle: const Text('Updates only when Wifi connected'),
                        value: state.isChapterDownloadWifiOnly,
                        onChanged: (bool value) {
                          settingsCubit.toggleChapterDownloadWifiOnly(value);
                        },
                      ),
                      ListTile(
                        title: const Text('Update Interval'),
                        subtitle: const Text('Interval for library update (in hours)'),
                        trailing: DropdownButton<String>(
                          value: state.autoUpdateIntervalInHours.toString(),
                          items: <String>['3', '6', '12', '24', '48', '72']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              settingsCubit.setAutoUpdateInterval(int.parse(newValue));
                            }
                          },
                        ),
                      ),
                      SectionHeader(title: 'Notifications'),
                      SwitchListTile(
                        title: const Text('Notify on favorite updated'),
                        subtitle: const Text('Send notification when favorite manga is updated'),
                        value: state.notifyIfFavoriteMangaUpdated,
                        onChanged: (bool value) {
                          settingsCubit.toggleNotifyIfFavoriteMangaUpdated(value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Notify on update finished'),
                        subtitle: const Text('Send notification when update is finished'),
                        value: state.showNotificationsAfterUpdate,
                        onChanged: (bool value) {
                          settingsCubit.toggleShowNotificationsAfterUpdate(value);
                        },
                      ),
                      SectionHeader(title: 'Manual Update'),
                      ListTile(
                        title: const Text('Update Library Now'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            SupabaseClient repository = Supabase.instance.client;
                            context.read<MangaLibraryCubit>().fetchLatestUpdates(repository, settingsCubit.state);
                          },
                          child: const Text('Update Now'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }
      ),
    );
  }
}