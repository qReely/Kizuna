import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/widgets/manga_search/manga_search_dialog.dart';
import 'package:manga_reader_app/features/home_page/bottom_nav_cubit.dart';

class ScaffoldWrapper extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showActions;
  final bool showBottomNavBar;
  final bool showSearch;

  const ScaffoldWrapper({
    super.key,
    required this.title,
    required this.body,
    this.showActions = true,
    this.showSearch = true,
    this.showBottomNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            scrolledUnderElevation: 0,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: false,
            actions: showActions ? [
              Visibility(
                visible: showSearch,
                child: const MangaSearchDialog(),
              ),
              BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
                builder: (context, state) {
                  return IconButton(
                    icon: FaIcon(
                      state.isGridView
                          ? FontAwesomeIcons.bars
                          : FontAwesomeIcons.borderAll,
                    ),
                    onPressed: () {
                      context.read<MangaLibraryCubit>().toggleView();
                    },
                  );
                },
              ),
            ] : [],
          ),
          body: body,
          bottomNavigationBar: Visibility(
            visible: showBottomNavBar,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                enableFeedback: false,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: const TextStyle(fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                onTap: (index) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  context.read<BottomNavCubit>().updateIndex(index);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: currentIndex == 0
                          ? BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      )
                          : null,
                      child: const FaIcon(FontAwesomeIcons.solidHouse),
                    ),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: currentIndex == 1
                          ? BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      )
                          : null,
                      child: const FaIcon(FontAwesomeIcons.clockRotateLeft),
                    ),
                    label: "History",
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: currentIndex == 2
                          ? BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      )
                          : null,
                      child: const FaIcon(FontAwesomeIcons.solidBookmark),
                    ),
                    label: "Categories",
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: currentIndex == 3
                          ? BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      )
                          : null,
                      child: const FaIcon(FontAwesomeIcons.ellipsis),
                    ),
                    label: "More",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}