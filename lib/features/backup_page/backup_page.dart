import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/cubit/backup_cubit/backup_cubit.dart';
import 'package:manga_reader_app/core/cubit/backup_cubit/backup_state.dart';
import 'package:manga_reader_app/core/widgets/custom_snackbar/custom_snackbar.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/core/widgets/section_header/section_header.dart';
import 'package:manga_reader_app/data/repositories/backup_repository.dart';
import 'package:manga_reader_app/features/settings_page/settings_cubit.dart';
import 'package:manga_reader_app/features/settings_page/settings_state.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        var re = await Permission.manageExternalStorage.request();
        if (re.isGranted) {
          return true;
        }
        return false;
      }
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final backupRepository = context.read<BackupRepository>();
    final backupCubit = context.read<BackupCubit>();

    return BlocListener<BackupCubit, BackupState>(
      listener: (context, state) {
        if (state is BackupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar(state.message),
          );
        } else if (state is BackupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<BackupCubit, BackupState>(
        builder: (context, state) {
          if (state is BackupLoading) {
            return Scaffold(
              body: LoadingAnimation(text: state.message,),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Backup & Restore'),
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                SectionHeader(title: 'Manual Backup & Restore'),
                ListTile(
                  title: const Text('Create Backup'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      bool isGranted = await _requestStoragePermission();
                      if (!isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Storage permission is required to create a backup.'),
                        );
                        return;
                      }
                      String? directoryPath = await FilePicker.platform.getDirectoryPath();
                      if (directoryPath != null) {
                        backupCubit.createBackupWithPath(directoryPath);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Directory selection canceled.'),
                        );
                      }
                    },
                    child: const Text('Create'),
                  ),
                ),
                ListTile(
                  title: const Text('Restore from file'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      bool isGranted = await _requestStoragePermission();
                      if (!isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Storage permission is required to restore a backup.'),
                        );
                        return;
                      }
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (result != null && result.files.single.path != null) {
                        String filePath = result.files.single.path!;
                        backupCubit.loadBackupWithPath(filePath);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Restore canceled.'),
                        );
                      }
                    },
                    child: const Text('Restore'),
                  ),
                ),
                SectionHeader(title: 'Auto-Backup'),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    final settingsCubit = context.read<SettingsCubit>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: const Text('Auto Backup'),
                          subtitle: const Text('Auto backup manga data'),
                          value: state.isAutoBackupEnabled,
                          onChanged: (bool value) {
                            settingsCubit.toggleAutoBackup(value);
                          },
                        ),
                        ListTile(
                          title: const Text('Backup Interval'),
                          subtitle: const Text('Interval for auto backup'),
                          trailing: DropdownButton<String>(
                            value: state.autoBackupIntervalInHours.toString(),
                            items: <String>['24', '48', '72', '96']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                settingsCubit.setAutoBackupInterval(int.parse(newValue));
                              }
                            },
                          ),
                        ),
                        FutureBuilder<File?>(
                          future: context.read<BackupRepository>().getLastBackupFile(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              final filePath = snapshot.data!.path;
                              final formattedTime = backupRepository.parseTimestampFromFilename(filePath);
                              if (formattedTime != null) {
                                return ListTile(
                                  title: const Text('Last Auto-Backup'),
                                  subtitle: Text('Executed on $formattedTime'),
                                );
                              }
                            }
                            return const ListTile(
                              title: Text('Last Auto-Backup'),
                              subtitle: Text('No backup found.'),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('Restore Auto-Backup'),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              try {
                                final backupFile = await context.read<BackupRepository>().getLastBackupFile();
                                if (backupFile != null) {
                                  await context.read<BackupRepository>().loadBackup(backupFile.path);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Auto-backup restored successfully!'),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('No auto-backup found to restore.'),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Failed to restore from auto-backup: $e'),
                                );
                              }
                            },
                            child: const Text('Restore'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}