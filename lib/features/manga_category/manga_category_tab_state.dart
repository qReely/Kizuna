import 'package:equatable/equatable.dart';

class MangaCategoryTabState extends Equatable {
  final int currentPage;

  const MangaCategoryTabState({
    this.currentPage = 1,
  });

  MangaCategoryTabState copyWith({
    int? currentPage,
    int? mangasPerPage,
  }) {
    return MangaCategoryTabState(
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [currentPage];
}