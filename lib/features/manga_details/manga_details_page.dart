import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_cubit.dart';
import 'package:manga_reader_app/core/cubit/manga_library_cubit/manga_library_state.dart';
import 'package:manga_reader_app/core/models/manga_view_model.dart';
import 'package:manga_reader_app/app/app_extensions.dart';
import 'package:manga_reader_app/core/widgets/custom_snackbar/custom_snackbar.dart';
import 'package:manga_reader_app/features/manga_details/manga_details_description_cubit.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/features/manga_chapters/manga_chapters.dart';
import 'package:flutter/services.dart';
import 'package:manga_reader_app/features/manga_genres/manga_selected_genre.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';


class MangaDetailsPage extends StatelessWidget {
  MangaDetailsPage({super.key, required this.manga});
  MangaView manga;
  List<ReadingStatus> options = ReadingStatus.values;
  final double imageHeight = 300;
  final double padding = 32;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MangaDetailsDescriptionCubit(),
          ),
        ],
        child: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
              ),
              extendBodyBehindAppBar: true,
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Opacity(
                          opacity: 0.33,
                          child: CachedNetworkImage(
                            alignment: Alignment.topCenter,
                            imageUrl: manga.image!,
                            height: imageHeight,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                            errorWidget: (context, error, trace) =>
                                SizedBox(
                                  height: imageHeight,
                                  width: MediaQuery.of(context).size.width,
                                ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16),
                            Padding(
                              padding: EdgeInsets.only(top: imageHeight/2 - 16, right: 16, bottom: 16),
                              child: Container(
                                height: imageHeight / 2,
                                width: (imageHeight / 2) * (2 / 3),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                      offset: const Offset(6, 6),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                      child: Hero(
                                        tag: manga.link,
                                        child: CachedNetworkImage(
                                          imageUrl: manga.image!,
                                          height: imageHeight / 2,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, error, trace) =>
                                              Container(
                                                height: imageHeight / 2,
                                                width: (imageHeight / 2) * (2 / 3),
                                                color: Colors.grey[300],
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                    color: Colors.grey[700],
                                                    size: (imageHeight / 2) * 0.6,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: InkWell(
                                          splashColor: Colors.white30,
                                          borderRadius: BorderRadius.circular(16.0),
                                          onTap: () {
                                            _showImageDialog(context, manga.image!);
                                          }
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: imageHeight/2 - 16, right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        Clipboard.setData(ClipboardData(text: manga.title));
                                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size,).getSnackBar("Manga Title copied to clipboard"),
                                        );
                                      },
                                      child:Text(manga.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1), overflow: TextOverflow.clip, maxLines: 2,),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          child: Center(
                                            child: const FaIcon(FontAwesomeIcons.circleInfo, size: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text("${manga.type}", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),),),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          child: Center(
                                            child: const FaIcon(FontAwesomeIcons.solidHourglassHalf, size: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text("${manga.status}", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),),),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          child: Center(
                                            child: const FaIcon(FontAwesomeIcons.scroll, size: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text("${manga.chapters.length} chapters", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),),),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          child: Center(
                                            child: const FaIcon(FontAwesomeIcons.penClip, size: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text("Author: ${manga.authors.map((author) => author.name).join(", ").isNotEmpty ? manga.authors.map((author) => author.name).join(", ") : "Unknown"}", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          child: Center(
                                            child: const FaIcon(FontAwesomeIcons.palette, size: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text("Artist: ${manga.artists.map((artist) => artist.name).join(", ").isNotEmpty ? manga.artists.map((artist) => artist.name).join(", ") : "Unknown"}", style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PreferredSize(
                      preferredSize: const Size.fromHeight(6),
                      child: LinearProgressIndicator(
                        value: context.read<MangaLibraryCubit>().getReadChapters(manga.title) / (manga.chapters.isEmpty ? 1 : manga.chapters.length),
                        minHeight: 10,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (manga.rating != null ) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (manga.rating != null)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const FaIcon(FontAwesomeIcons.solidStar, size: 16, color: Colors.amber),
                                        const SizedBox(height: 4),
                                        Text(
                                          manga.rating!.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                          "Rating",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: GestureDetector(
                                    child: const Column(
                                      children: [
                                        FaIcon(FontAwesomeIcons.globe, size: 16, color: Colors.green),
                                        SizedBox(height: 4),
                                        Text(
                                          "Manga",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Link",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: manga.link));
                                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size,).getSnackBar("Manga Link copied to clipboard"),
                                      );
                                    },
                                  ),
                                ),
                                const Expanded(
                                  child: Column(
                                    children: [
                                      FaIcon(FontAwesomeIcons.users, size: 16, color: Colors.blue),
                                      SizedBox(height: 4),
                                      Text(
                                        "123",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Followers",
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 155,
                                  child: BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
                                    builder: (context, status) {
                                      Color selectedColor = context.read<MangaLibraryCubit>().getStatus(manga.link).color;
                                      return ElevatedButton(
                                        style: ButtonStyle(
                                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                side: BorderSide(width: 2, color: selectedColor)
                                            ),
                                          ),
                                          elevation: WidgetStateProperty.all(0),
                                          shadowColor: WidgetStateProperty.all(Colors.transparent),
                                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                        ),
                                        onPressed: () async {
                                          final selectedStatus = await _showReadingStatusDialog(context, options, manga.link);
                                          if (selectedStatus != null) {
                                            context.read<MangaLibraryCubit>().updateStatus(manga.link, selectedStatus);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              context.read<MangaLibraryCubit>().getStatus(manga.link).name,
                                              style: TextStyle(color: selectedColor),
                                            ),
                                            const SizedBox(width: 4,),
                                            FaIcon(FontAwesomeIcons.caretDown, color: selectedColor,),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                BlocBuilder<MangaLibraryCubit, MangaLibraryState>(
                                  builder: (context, state) {
                                    bool isFavorite = context.read<MangaLibraryCubit>().isFavorite(manga.link);
                                    Color paintColor = isFavorite ? Colors.deepPurple : Colors.grey[500]!;
                                    return ElevatedButton(
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                                              side: BorderSide(width: 2, color: paintColor)
                                          ),
                                        ),
                                        elevation: WidgetStateProperty.all(0),
                                        shadowColor: WidgetStateProperty.all(Colors.transparent),
                                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                      ),
                                      onPressed: () {
                                        context.read<MangaLibraryCubit>().toggleFavorite(manga.link);
                                      },
                                      child: FaIcon(
                                        context.read<MangaLibraryCubit>().isFavorite(manga.link) ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                        size: 18,
                                        color: Colors.deepPurple,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Synopsis",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<MangaDetailsDescriptionCubit, bool>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      constraints: context.read<MangaDetailsDescriptionCubit>().state
                                          ? const BoxConstraints(maxHeight: 10000)
                                          : const BoxConstraints(maxHeight: 60),
                                      child: Text(
                                        manga.synopsis!,
                                        style: const TextStyle(fontSize: 14),
                                        overflow: context.read<MangaDetailsDescriptionCubit>().state
                                            ? TextOverflow.visible
                                            : TextOverflow.fade,
                                      ),
                                    ),
                                    onTap: () {
                                      context.read<MangaDetailsDescriptionCubit>().showDescription();
                                    }
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Genres",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: manga.genres.map(
                                  (genre) => TextButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Theme.of(context).canvasColor),
                                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      side: BorderSide(width: 2, color: Theme.of(context).hintColor),
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    ),
                                  ),
                                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MangaSelectedGenre(selectedGenre: genre.name),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const FaIcon(FontAwesomeIcons.tag, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      genre.get().capitalize(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ),
                          const SizedBox(height: 66),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Container(
                width: 80,
                height: 48,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(25),
                    right: Radius.circular(25),
                  ),
                ),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: const FaIcon(FontAwesomeIcons.bookOpenReader, size: 32,),
                    ),
                    SizedBox.expand(
                      child: Material(
                        type: MaterialType.transparency,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                        child: InkWell(
                          splashColor: Colors.white30,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(25),
                            right: Radius.circular(25),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MangaChapters(manga: manga)));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}

Future<void> _downloadAndSaveImage(String imageUrl, BuildContext context) async {

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if(!re.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Storage permission denied'),
        );
      }
    }
  }

  try {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Downloading image...'),
    );

    var response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${DateTime.now().toIso8601String()}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      await Gal.putImage(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Image saved to gallery!'),
      );

      await file.delete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('Failed to download image'),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar(theme: Theme.of(context), size: MediaQuery.of(context).size).getSnackBar('An error occured: $e'),
    );
  }
}


void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            InteractiveViewer(
              maxScale: 2,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, error, trace) =>
                Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 15,
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.solidCircleXmark, color: Colors.white, size: 36,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            if (imageUrl.startsWith('http'))
              Positioned(
                top: 40,
                right: 15,
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.solidCircleDown, color: Colors.white, size: 36,),
                  onPressed: () {
                    _downloadAndSaveImage(imageUrl, context);
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        );
      },
  );
}

Future<ReadingStatus?> _showReadingStatusDialog(
    BuildContext context, List<ReadingStatus> options, String mangaLink) {
  return showDialog<ReadingStatus>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Center(child: Text('Select Reading Status'),),
        titleTextStyle: const TextStyle(fontSize: 18),
        content: SingleChildScrollView(
          child: ListBody(
            children: options.map((option) {
              return ListTile(
                leading: context.read<MangaLibraryCubit>().getStatus(mangaLink) == option ? const Icon(Icons.radio_button_checked, size: 16,) : const Icon(Icons.radio_button_off, size: 16,),
                title: Text(option.name),
                onTap: () {
                  Navigator.of(context).pop(option);
                },
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}



