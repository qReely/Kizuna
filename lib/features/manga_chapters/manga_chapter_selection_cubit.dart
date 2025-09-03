import 'package:bloc/bloc.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'dart:math';

class SelectionCubit extends Cubit<Set<int>> {
  SelectionCubit() : super({});


  void toggleSelection(int chapterId) {
    final newSelection = Set<int>.from(state);
    if (newSelection.contains(chapterId)) {
      newSelection.remove(chapterId);
    } else {
      newSelection.add(chapterId);
    }
    emit(newSelection);
  }

  void toggleRangeSelection(int chapterId, List<Chapter> allChapters) {
    final updatedSelection = Set<int>.from(state);
    if (updatedSelection.isEmpty) {
      updatedSelection.add(chapterId);
    } else {
      final smallestSelectedChapterId = updatedSelection.reduce(min);

      final newChapterIndex = allChapters.indexWhere((c) => c.id == chapterId);
      final smallestIdIndex = allChapters.indexWhere((c) => c.id == smallestSelectedChapterId);

      if (newChapterIndex != -1 && smallestIdIndex != -1) {
        final startIndex = min(newChapterIndex, smallestIdIndex);
        final endIndex = max(newChapterIndex, smallestIdIndex);

        for (int i = startIndex; i <= endIndex; i++) {
          final chapterToSelectId = allChapters[i].id  ?? -1;
          updatedSelection.add(chapterToSelectId);
        }
      }
    }
    emit(updatedSelection);
  }

  void clearSelection() {
    emit({});
  }

  void selectAll(List<Chapter> chapters) {
    final allChapterIds = chapters.map((c) => c.id  ?? -1).toSet();
    emit(allChapterIds);
  }
}