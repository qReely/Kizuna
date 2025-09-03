import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';

class ChapterCubit extends Cubit<List<Chapter>> {
  ChapterCubit(super.initialChapters);

  void reverseChapters() {
    emit(state.reversed.toList());
  }

  void setChapters(List<Chapter> chapters) {
    emit(List.from(chapters));
  }

}