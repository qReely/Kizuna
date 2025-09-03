import 'package:flutter_bloc/flutter_bloc.dart';

import 'manga_genres_state.dart';

class GenresTabCubit extends Cubit<GenresTabState> {
  GenresTabCubit() : super(const GenresTabState());

  void changePage(int page) {
    emit(state.copyWith(currentPage: page));
  }
}