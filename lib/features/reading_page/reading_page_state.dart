import 'package:equatable/equatable.dart';

abstract class ReadingPageState extends Equatable {
  const ReadingPageState();

  @override
  List<Object> get props => [];
}

class ReadingPageInitial extends ReadingPageState {}

class ReadingPageLoading extends ReadingPageState {}

class ReadingPageLoaded extends ReadingPageState {
  final List<String> imageUrls;
  final int lastPageIndex;
  final int currentChapterId;

  const ReadingPageLoaded({
    required this.imageUrls,
    required this.lastPageIndex,
    required this.currentChapterId,
  });

  ReadingPageLoaded copyWith({
    List<String>? imageUrls,
    int? lastPageIndex,
    int? currentChapterId,
  }) {
    return ReadingPageLoaded(
      imageUrls: imageUrls ?? this.imageUrls,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      currentChapterId: currentChapterId ?? this.currentChapterId,
    );
  }

  @override
  List<Object> get props => [
    imageUrls,
    lastPageIndex,
    currentChapterId,
  ];
}

class ReadingPageError extends ReadingPageState {
  final String message;

  const ReadingPageError({required this.message});

  @override
  List<Object> get props => [message];
}
