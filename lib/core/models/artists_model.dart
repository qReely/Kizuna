import 'package:hive_ce/hive.dart';

class Artist extends HiveObject {
  final String name;

  Artist({required this.name});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(name: json['name']);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
  };
}