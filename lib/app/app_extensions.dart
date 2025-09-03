import 'package:manga_reader_app/core/models/manga_view_model.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

extension IterableExtension<T> on Iterable<MangaView> {
  List<MangaView> sorted(int Function(MangaView a, MangaView b) compare) {
    final list = [...this];
    list.sort(compare);
    return list;
  }
}