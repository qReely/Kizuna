import 'package:hive_ce/hive.dart';


class Chapter extends HiveObject {
  final int? id;
  final String link;
  final String title;
  final String? released;

  Chapter({
    this.id,
    required this.link,
    required this.title,
    this.released,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int?,
      link: json['link'] as String,
      title: json['title'] as String,
      released: json['released'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'link': link,
      'title': title,
      'released': released,
    };
  }
}