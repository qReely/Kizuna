import 'package:manga_reader_app/core/models/artists_model.dart';
import 'package:manga_reader_app/core/models/authors_model.dart';
import 'package:manga_reader_app/core/models/chapters_model.dart';
import 'package:manga_reader_app/core/models/genres_model.dart';
import 'package:hive_ce/hive.dart';

class Manga extends HiveObject {
  final int? id;
  final String title;
  final String link;
  final String? status;
  final String? image;
  final String? type;
  final String? lastChapter;
  final double? rating;
  final int? followedBy;
  final String? synopsis;
  final String? serialization;
  final String? updatedOn;
  final int? totalChapters;
  final int? order;
  final List<Author> authors;
  final List<Artist> artists;
  final List<Genre> genres;
  List<Chapter> chapters;

  Manga({
    this.id,
    required this.title,
    required this.link,
    this.status,
    this.image,
    this.type,
    this.lastChapter,
    this.rating,
    this.followedBy,
    this.synopsis,
    this.serialization,
    this.updatedOn,
    this.totalChapters,
    this.order,
    this.authors = const [],
    this.artists = const [],
    this.genres = const [],
    this.chapters = const [],
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] as int?,
      title: json['title'] as String,
      link: json['link'] as String,
      status: json['status'] as String?,
      image: json['image'] as String?,
      type: json['type'] as String?,
      lastChapter: json['last_chapter'] as String?,
      rating: json['rating'] as double?,
      followedBy: json['followed_by'] as int?,
      synopsis: json['synopsis'] as String?,
      serialization: json['serialization'] as String?,
      updatedOn: json['updated_on'] as String?,
      totalChapters: json['total_chapters'] as int?,
      order: json['order'] as int?,
      authors: (json['authors'] as List<dynamic>?)
          ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      artists: (json['artists'] as List<dynamic>?)
          ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'status': status,
      'image': image,
      'type': type,
      'last_chapter': lastChapter,
      'rating': rating,
      'followed_by': followedBy,
      'synopsis': synopsis,
      'serialization': serialization,
      'updated_on': updatedOn,
      'total_chapters': totalChapters,
      'order': order,
      'authors': authors.map((e) => e.toJson()).toList(),
      'artists': artists.map((e) => e.toJson()).toList(),
      'genres': genres.map((e) => e.toJson()).toList(),
      'chapters': chapters.map((e) => e.toJson()).toList(),
    };
  }
}