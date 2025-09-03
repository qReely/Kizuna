import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/error_page/error_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/data/repositories/user_manga_repository.dart';
import 'package:manga_reader_app/features/reading_page/reading_page_cubit.dart';
import 'package:manga_reader_app/features/reading_page/reading_page_state.dart';
import 'package:manga_reader_app/features/reading_page/reading_page_app_bar_cubit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

final customCacheManager = CacheManager(
  Config(
    'mangaImageCache',
    maxNrOfCacheObjects: 100,
    stalePeriod: const Duration(days: 1),
  ),
);

typedef OnReadingPageClosed = void Function(int elapsedTimeInSeconds);

class ReadingPage extends StatefulWidget {
  final MangaView mangaView;
  final Chapter chapter;
  final OnReadingPageClosed onClose;

  const ReadingPage({
    super.key,
    required this.mangaView,
    required this.chapter,
    required this.onClose,
  });

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> with WidgetsBindingObserver {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late DateTime _startTime;
  DateTime? _pauseTime;
  int _totalPausedSeconds = 0;
  bool _isInitialLoad = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }


  void _updateBookmarkStatus(BuildContext context, bool isBookmarked) {
    final libraryCubit = context.read<MangaLibraryCubit>();
    libraryCubit.toggleChapterBookmark(
      widget.mangaView.link,
      [widget.chapter.id ?? -1],
      isBookmarked: isBookmarked,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    final int totalReadingSeconds = DateTime.now().difference(_startTime).inSeconds - _totalPausedSeconds;
    widget.onClose(totalReadingSeconds);
    print('ReadingPage: Disposing, total reading seconds: $totalReadingSeconds');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _pauseTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        if (_pauseTime != null) {
          final int elapsedSeconds = DateTime.now().difference(_pauseTime!).inSeconds;
          _totalPausedSeconds += elapsedSeconds;
          _pauseTime = null;
        }
        break;
      default:
        break;
    }
  }

  void _onTap(TapUpDetails details, ReadingPageCubit readingPageCubit, ReadingPageAppBarCubit appBarCubit) {
    final screenHeight = MediaQuery.of(context).size.height;
    final tapY = details.globalPosition.dy;

    if (tapY < screenHeight / 5) {
      _scrollToPreviousPage(readingPageCubit);
    } else if (tapY > screenHeight * 7 / 8) {
      _scrollToNextPage(readingPageCubit, appBarCubit);
    } else {
      appBarCubit.toggleAppBarVisibility();
    }
  }

  void _scrollToPreviousPage(ReadingPageCubit cubit) {
    final currentState = cubit.state;
    if (currentState is ReadingPageLoaded) {
      final currentVisibleIndex = itemPositionsListener.itemPositions.value.first.index;
      if (currentVisibleIndex > 0) {
        final targetIndex = currentVisibleIndex - 1;
        itemScrollController.jumpTo(index: targetIndex);
        cubit.updateCurrentPageIndex(targetIndex);
      }
    }
  }

  void _scrollToNextPage(ReadingPageCubit cubit, ReadingPageAppBarCubit appBarCubit) {
    final currentState = cubit.state;
    if (currentState is ReadingPageLoaded) {
      final currentVisibleIndex = itemPositionsListener.itemPositions.value.first.index;
      if (currentVisibleIndex < currentState.imageUrls.length - 1) {
        final targetIndex = currentVisibleIndex + 1;
        itemScrollController.jumpTo(index: targetIndex);
        cubit.updateCurrentPageIndex(targetIndex);
      } else {
        cubit.loadNextChapter();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ReadingPage: Rebuilding entire page for chapter ${widget.chapter.id}');
    final initialLastPageRead = widget.mangaView.getLastPageRead(widget.chapter.id ?? 0);
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            print('ReadingPage: Creating ReadingPageCubit with initialLastPageRead: $initialLastPageRead');
            return ReadingPageCubit(
              context.read<UserMangaRepository>(),
              widget.mangaView,
              widget.chapter.id ?? -1,
              initialLastPageRead,
            );
          },
        ),
        BlocProvider(
          create: (_) => ReadingPageAppBarCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final readingPageCubit = context.read<ReadingPageCubit>();
          final appBarCubit = context.read<ReadingPageAppBarCubit>();
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              final libraryCubit = context.read<MangaLibraryCubit>();
              if (readingPageCubit.state is ReadingPageLoaded) {
                final loadedState = readingPageCubit.state as ReadingPageLoaded;
                await libraryCubit.updateReadingProgress(
                  mangaLink: widget.mangaView.link,
                  chapterId: loadedState.currentChapterId,
                  lastPageRead: loadedState.lastPageIndex,
                );
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: BlocListener<ReadingPageCubit, ReadingPageState>(
              listener: (context, state) {
                if (state is ReadingPageLoaded) {
                  if (_isInitialLoad) {
                    _isInitialLoad = false;
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (initialLastPageRead > 0 && itemScrollController.isAttached) {
                        print('ReadingPage: Jumping to initial page $initialLastPageRead');
                        itemScrollController.jumpTo(index: initialLastPageRead);
                      }
                    });
                  }
                }
              },
              child: BlocBuilder<ReadingPageAppBarCubit, bool>(
                builder: (context, appBarState) {
                  return Scaffold(
                    key: _scaffoldKey,
                    appBar: appBarState
                        ? AppBar(
                      title: BlocSelector<ReadingPageCubit, ReadingPageState, String>(
                        selector: (state) {
                          if (state is ReadingPageLoaded) {
                            final index = context.read<ReadingPageCubit>().currentChapterIndex;
                            return widget.mangaView.chapters[index].title;
                          }
                          return '';
                        },
                        builder: (context, chapterTitle) {
                          return Text(chapterTitle);
                        },
                      ),
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(120),
                      actions: [
                        IconButton(
                          onPressed: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          icon: const Icon(Icons.list),
                        ),
                      ],
                    )
                        : null,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    extendBodyBehindAppBar: true,
                    body: GestureDetector(
                      onTapUp: (details) => _onTap(details, readingPageCubit, appBarCubit),
                      child: BlocBuilder<ReadingPageCubit, ReadingPageState>(
                        builder: (context, state) {
                          if (state is ReadingPageLoaded) {
                            return NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification notification) {
                                if (notification is ScrollEndNotification) {
                                  final metrics = notification.metrics;
                                  if (metrics.pixels == metrics.maxScrollExtent) {
                                    readingPageCubit.loadNextChapter();
                                  }
                                }
                                if (itemPositionsListener.itemPositions.value.isNotEmpty) {
                                  final firstVisibleItem = itemPositionsListener.itemPositions.value.first;
                                  final clampedIndex = firstVisibleItem.index.clamp(0, state.imageUrls.length - 1);
                                  if (state.lastPageIndex != clampedIndex) {
                                    _debounceTimer?.cancel();
                                    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
                                      readingPageCubit.updateCurrentPageIndex(clampedIndex);
                                    });
                                  }
                                }
                                return false;
                              },
                              child: Stack(
                                children: [
                                  ScrollablePositionedList.builder(
                                    key: ValueKey(widget.chapter.id), // Ensure list retains state
                                    itemCount: state.imageUrls.length,
                                    itemScrollController: itemScrollController,
                                    itemPositionsListener: itemPositionsListener,
                                    physics: const ClampingScrollPhysics().applyTo(
                                      const AlwaysScrollableScrollPhysics(),
                                    ),
                                    itemBuilder: (context, index) {
                                      final imageUrl = state.imageUrls[index];
                                      return _buildImage(imageUrl);
                                    },
                                  ),
                                  BlocSelector<ReadingPageCubit, ReadingPageState, int>(
                                    selector: (state) => state is ReadingPageLoaded ? state.lastPageIndex : 0,
                                    builder: (context, lastPageIndex) {
                                      return Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            "${lastPageIndex + 1}/${(context.read<ReadingPageCubit>().state as ReadingPageLoaded).imageUrls.length}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else if (state is ReadingPageLoading) {
                            return const LoadingAnimation(text: "Loading Chapter");
                          } else if (state is ReadingPageError) {
                            return ErrorPage(errorMessage: state.message);
                          } else {
                            return const EmptyPage(text: "Unexpected state");
                          }
                        },
                      ),
                    ),
                    endDrawer: Drawer(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ListView.builder(
                        itemCount: widget.mangaView.manga.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = widget.mangaView.manga.chapters[index];
                          return ListTile(
                            title: Text(chapter.title),
                            selected: chapter.id == widget.chapter.id,
                            onTap: () {
                              context.read<ReadingPageCubit>().loadNextChapterByIndex(index);
                              _scaffoldKey.currentState?.closeEndDrawer();
                              context.read<ReadingPageAppBarCubit>().toggleAppBarVisibility();
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return imageUrl.startsWith("http")
        ? CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: customCacheManager,
      fit: BoxFit.fitWidth,
      filterQuality: FilterQuality.low,
      progressIndicatorBuilder: (context, child, progress) {
        return AspectRatio(
          aspectRatio: 9 / 16,
          child: Center(
            child: CircularProgressIndicator(value: progress.progress),
          ),
        );
      },
    )
        : Container(
      constraints: const BoxConstraints(minHeight: 200),
      child: Image.file(File(imageUrl)),
    );
  }
}