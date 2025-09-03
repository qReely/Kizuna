import 'package:equatable/equatable.dart';
import 'package:manga_reader_app/core/enums/chapter_download_status.dart';

class ChapterDownloadState extends Equatable {
  final ChapterDownloadStatus status;
  final double? progress;
  final int? chapterId;
  final String? message;
  final String? error;

  const ChapterDownloadState({
    required this.status,
    this.progress,
    this.chapterId,
    this.message,
    this.error,
  });

  ChapterDownloadState copyWith({
    ChapterDownloadStatus? status,
    double? progress,
    int? chapterId,
    String? message,
    String? error,
  }) {
    return ChapterDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      chapterId: chapterId ?? this.chapterId,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, progress, chapterId, message, error];
}