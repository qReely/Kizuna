import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:manga_reader_app/core/models/mangas_model.dart';

class MangaApiService {
  final SupabaseClient _supabaseClient;

  MangaApiService(this._supabaseClient);

  Future<List<Manga>> fetchAllMangas() async {
    final response = await _supabaseClient.rpc('get_all_mangas');
    return (response as List).map((item) => Manga.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<String>> getChapterImages(int chapterId) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_chapter_images',
        params: {'_chapter_id': chapterId},
      );
      if (response is List) {
        return response.map<String>((item) => item['image_url'] as String).toList();
      }
      return [];
    } catch (e) {
      if(kDebugMode) {
        debugPrint('Error retrieving chapter images: $e');
      }
      return [];
    }
  }
}