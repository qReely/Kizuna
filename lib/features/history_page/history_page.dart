import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/core/widgets/empty_page/empty_page.dart';
import 'package:manga_reader_app/core/widgets/loading_animation/loading_animation.dart';
import 'package:manga_reader_app/features/reading_page/reading_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _getFormattedDateCategory(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final week = DateTime(now.year, now.month, now.day - 7);
    final month = DateTime(now.year, now.month - 1, now.day);
    final timestampDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (timestampDate == today) {
      return "Today";
    } else if (timestampDate == yesterday) {
      return "Yesterday";
    } else if (timestampDate.isAfter(yesterday) && timestampDate.isBefore(week)) {
      return "This Week";
    } else if (timestampDate.isAfter(week) && timestampDate.isBefore(month)) {
      return "This Month";
    } else {
      return DateFormat('EEEE, MMMM d, y').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingAnimation(text: "Loading History");
          }

          final List<MangaView> historyList = context.read<MangaLibraryCubit>().state.mangaViews
              .where((mangaView) => mangaView.userManga?.lastReadTimestamp != null)
              .toList();

          historyList.sort((a, b) {
            return b.userManga!.lastReadTimestamp!.compareTo(a.userManga!.lastReadTimestamp!);
          });

          if (historyList.isEmpty) {
            return const EmptyPage(text: "No reading history found");
          }

          final Map<String, List<MangaView>> groupedHistory = {};
          for (var mangaView in historyList) {
            final mostRecentTimestamp = mangaView.userManga!.lastReadTimestamp!;
            final category = _getFormattedDateCategory(mostRecentTimestamp);

            if (!groupedHistory.containsKey(category)) {
              groupedHistory[category] = [];
            }
            groupedHistory[category]!.add(mangaView);
          }

          final List<Widget> flattenedList = [];
          groupedHistory.forEach((category, mangaViews) {
            flattenedList.add(
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            );
            for (var mangaView in mangaViews) {
              final mostRecentTimestamp = mangaView.userManga!.lastReadTimestamp!;
              final lastChapterId = mangaView.userManga!.lastChapterRead;

              void handleReadingPageClose(int elapsedTimeInSeconds) {
                context.read<MangaLibraryCubit>().updateTotalReadingTime(
                  mangaLink: mangaView.link,
                  seconds: elapsedTimeInSeconds,
                );
              }

              final lastChapter = mangaView.chapters.firstWhere(
                    (c) => c.id == lastChapterId,
                orElse: () => Chapter(id: 0, title: 'Unknown Chapter', link: 'link', released: ''),
              );

              final String formattedTime = DateFormat('HH:mm').format(mostRecentTimestamp);

              flattenedList.add(
                ListTile(
                  leading: mangaView.image != null
                      ? CachedNetworkImage(
                    imageUrl: mangaView.image!,
                    imageBuilder: (context, imageProvider) =>
                        Container(
                          height: 90,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    placeholder: (context, url) => Container(
                      height: 90,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 90,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.error),
                    ),
                  )
                      : const Icon(Icons.menu_book),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      mangaView.title,
                      maxLines: 2,
                      style: const TextStyle(height: 1.2, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  subtitle: Text(
                    '${lastChapter.title} at $formattedTime',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ReadingPage(
                          mangaView: mangaView,
                          chapter: lastChapter,
                          onClose: (elapsedSeconds) {
                            handleReadingPageClose(elapsedSeconds);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          });

          return ListView.builder(
            itemCount: flattenedList.length,
            itemBuilder: (context, index) {
              return flattenedList[index];
            },
          );
        },
      ),
    );
  }
}