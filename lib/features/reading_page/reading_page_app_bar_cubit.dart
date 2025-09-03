import 'package:flutter_bloc/flutter_bloc.dart';

class ReadingPageAppBarCubit extends Cubit<bool> {


  ReadingPageAppBarCubit() : super(false);

  void toggleAppBarVisibility() => emit(!state);

}