import 'package:equatable/equatable.dart';

class GenresTabState extends Equatable {
  final int currentPage;

  const GenresTabState({
    this.currentPage = 1,
  });

  GenresTabState copyWith({
    int? currentPage,
    int? mangasPerPage,
  }) {
    return GenresTabState(
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [currentPage];
}