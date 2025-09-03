import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:manga_reader_app/data/repositories/backup_repository.dart';
import 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  final BackupRepository _backupRepository;
  final RootIsolateToken _rootIsolateToken;

  BackupCubit(this._backupRepository, this._rootIsolateToken)
      : super(BackupInitial());


  Future<void> createBackupWithPath(String directoryPath) async {
    try {
      emit(BackupLoading(message: "Creating a Back-up"));
      await _backupRepository.createBackup(directoryPath);
      emit(const BackupSuccess(message: 'Backup created successfully!'));
    } catch (e) {
      emit(BackupError(message: 'Failed to create backup: $e'));
    }
  }

  Future<void> loadBackupWithPath(String filePath) async {
    try {
      emit(BackupLoading(message: "Restoring a Back-up"));
      await _backupRepository.loadBackup(filePath);
      emit(const BackupSuccess(message: 'Backup loaded successfully!'));
    } catch (e) {
      emit(BackupError(message: 'Failed to load backup: $e'));
    }
  }

  Future<void> createBackup() async {
    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(_rootIsolateToken);

      final directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        emit(BackupInitial());
        return;
      }

      emit(BackupLoading(message: "Creating a Back-up"));
      await _backupRepository.createBackup(directoryPath);
      emit(const BackupSuccess(message: 'Backup created successfully!'));
    } catch (e) {
      emit(BackupError(message: 'Failed to create backup: $e'));
    }
  }

  Future<void> loadBackup() async {
    try {
      BackgroundIsolateBinaryMessenger.ensureInitialized(_rootIsolateToken);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        emit(BackupLoading(message: "Restoring a Back-up"));
        final filePath = result.files.single.path!;
        await _backupRepository.loadBackup(filePath);
        emit(const BackupSuccess(message: 'Backup loaded successfully!'));
      } else {
        emit(BackupInitial());
      }
    } catch (e) {
      emit(BackupError(message: 'Failed to load backup: $e'));
    }
  }
}
