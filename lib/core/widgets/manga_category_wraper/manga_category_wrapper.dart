import 'package:flutter/material.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/features/manga_category/manga_category_page.dart';

class MangaCategoryWrapper extends StatefulWidget {
  const MangaCategoryWrapper({super.key});

  @override
  State<MangaCategoryWrapper> createState() => _MangaCategoryWrapperState();
}

class _MangaCategoryWrapperState extends State<MangaCategoryWrapper>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final reorderedStatuses = [
    null,
    ...ReadingStatus.values.skip(1),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: reorderedStatuses.length,
      initialIndex: 0,
      animationDuration: Duration.zero,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MangaCategoryPage(
      tabController: _tabController,
      reorderedStatuses: reorderedStatuses,
    );
  }
}