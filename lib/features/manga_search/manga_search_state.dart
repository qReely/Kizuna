import 'package:equatable/equatable.dart';

class SearchPageState extends Equatable {
  final int currentPage;

  const SearchPageState({
    this.currentPage = 1,
  });

  SearchPageState copyWith({
    int? currentPage,
  }) {
    return SearchPageState(
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [currentPage];
}