import 'package:hive_ce/hive.dart';
import 'package:manga_reader_app/core/models/artists_model.dart';
import 'package:manga_reader_app/core/models/authors_model.dart';
import 'package:manga_reader_app/core/models/chapters_data_model.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/genres_model.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';
import 'package:manga_reader_app/core/enums/reading_status_enum.dart';
import 'package:manga_reader_app/core/models/user_manga_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([AdapterSpec<ReadingStatus>(),AdapterSpec<Artist>(),AdapterSpec<Author>(),AdapterSpec<Chapter>(),AdapterSpec<Genre>(),AdapterSpec<Manga>(), AdapterSpec<UserManga>(), AdapterSpec<ChaptersDataModel>()])
// Annotations must be on some element
// ignore: unused_element
void _() {}