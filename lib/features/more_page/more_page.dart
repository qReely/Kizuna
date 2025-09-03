import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader_app/core/widgets/section_header/section_header.dart';
import 'package:manga_reader_app/features/backup_page/backup_page.dart';
import 'package:manga_reader_app/features/library_page/library_page.dart';
import 'package:manga_reader_app/features/settings_page/settings_page.dart';
import 'package:manga_reader_app/features/statistics_page/statistics_page.dart';
import 'package:manga_reader_app/features/manga_genres/manga_genres.dart';
import 'package:manga_reader_app/features/downloads_page/downloads_page.dart';
import 'package:manga_reader_app/features/app_info_page/app_info_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SectionHeader(title: 'General'),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.gear),
          title: const Text('Settings'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.circleInfo),
          title: const Text('App Info'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppInfoPage()),
            );
          },
        ),
        SectionHeader(title: 'Content'),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.tag),
          title: const Text('Genres'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MangaGenres()),
            );
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.chartLine),
          title: const Text('Statistics'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatisticsPage()),
            );
          },
        ),
        SectionHeader(title: 'Library'),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.book),
          title: const Text('Library Updates'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LibraryUpdatesPage()),
            );
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.database),
          title: const Text('Downloads'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DownloadedChaptersPage()),
            );
          },
        ),
        SectionHeader(title: 'Data'),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.upload),
          title: const Text('Backup & Restore'),
          trailing: const FaIcon(FontAwesomeIcons.angleRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BackupPage()),
            );
          },
        ),
      ],
    );
  }
}
