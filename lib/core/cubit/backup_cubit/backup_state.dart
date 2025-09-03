import 'package:equatable/equatable.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object> get props => [];
}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {
  final String message;
  const BackupLoading({required this.message});
}

class BackupSuccess extends BackupState {
  final String message;

  const BackupSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class BackupError extends BackupState {
  final String message;

  const BackupError({required this.message});

  @override
  List<Object> get props => [message];
}
