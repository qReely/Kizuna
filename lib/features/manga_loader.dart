import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_reader_app/core/widgets/custom_snackbar/custom_snackbar.dart';
import 'package:manga_reader_app/core/widgets/scaffold_wrapper/scaffold_wrapper.dart';
import 'package:manga_reader_app/features/home_page/bottom_nav_cubit.dart';
import 'package:manga_reader_app/features/manga_category/manga_category_page.dart';
import 'package:manga_reader_app/features/home_page/manga_viewer.dart';
import 'package:manga_reader_app/features/more_page/more_page.dart';
import '../core/widgets/manga_category_wraper/manga_category_wrapper.dart';
import 'history_page/history_page.dart';


class MangaLoader extends StatelessWidget {
  final List<Widget> pages = [
    const MangaViewer(),
    const HistoryPage(),
    MangaCategoryWrapper (),
    const MorePage(),
  ];

  final List<String> pageTitles = [
    "Kizuna",
    "History",
    "Categories",
    "More",
  ];

  MangaLoader({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        final now = DateTime.now();
        final backButtonHasBeenPressedOnce = lastPressed != null &&
            now.difference(lastPressed!) < const Duration(seconds: 2);

        lastPressed = now;

        if (backButtonHasBeenPressedOnce) {
          if (Platform.isAndroid || Platform.isIOS) {
            exit(0);
          } else {
            Navigator.of(context).pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Press back again to exit'),
          );
        }
      },
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, currentIndex) {
          return ScaffoldWrapper(
            title: pageTitles[currentIndex],
            body: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          );
        },
      ),
    );
  }
}