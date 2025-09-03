import 'package:hive_ce/hive.dart';

class ChaptersDataModel extends HiveObject {
  final String chapterId;
  List<String> imageUrls;
  List<String> imagePaths;

  ChaptersDataModel({
    required this.chapterId,
    required this.imageUrls,
    required this.imagePaths,
  });

  factory ChaptersDataModel.fromJson(Map<String, dynamic> json) {
    return ChaptersDataModel(
      chapterId: json['chapter_id'],
      imageUrls: json['image_urls'] ?? [],
      imagePaths: json['image_paths'] ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'chapter_id': chapterId,
    'image_urls': imageUrls,
    'image_paths': imagePaths,
  };
}