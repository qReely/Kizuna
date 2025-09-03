import 'package:bloc/bloc.dart';

class MangaDetailsDescriptionCubit extends Cubit<bool> {
  MangaDetailsDescriptionCubit() : super(false);

  void showDescription() {
    emit(!state);
  }

  String getButtonText() {
    return state ? "Show less" : "Show more";
  }

}
