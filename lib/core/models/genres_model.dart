import 'package:hive_ce/hive.dart';

class Genre extends HiveObject {
  final String name;

  Genre({required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(name: json['name']);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
  };

  String get(){
    return name;
  }
}