import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/widgets/custom_tab_bar_physics/custom_tab_bar_physics.dart';
import 'package:manga_reader_app/features/manga_category/manga_category_tab.dart';

class MangaCategoryPage extends StatelessWidget {
  final TabController tabController;
  const MangaCategoryPage({super.key, required this.tabController, required this.reorderedStatuses});
  final List<ReadingStatus?> reorderedStatuses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: reorderedStatuses.map((status) {
            return Tab(text: status?.name ?? 'Favorite');
          }).toList(),
        ),
      ),
      body: TabBarView(
        physics: CustomTabBarViewPhysics(),
        controller: tabController,
        children: reorderedStatuses.map((status) {
          return MangaCategoryTab(status: status);
        }).toList(),
      ),
    );
  }
}
