import 'package:flutter_bloc/flutter_bloc.dart';

import 'manga_search_state.dart';

class SearchPageCubit extends Cubit<SearchPageState> {
  SearchPageCubit() : super(const SearchPageState());

  void changePage(int page) {
    emit(state.copyWith(currentPage: page));
  }
}