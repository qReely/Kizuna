import 'package:flutter_bloc/flutter_bloc.dart';

import 'manga_category_tab_state.dart';

class MangaCategoryTabCubit extends Cubit<MangaCategoryTabState> {
  MangaCategoryTabCubit() : super(const MangaCategoryTabState());

  void changePage(int page) {
    emit(state.copyWith(currentPage: page));
  }
}