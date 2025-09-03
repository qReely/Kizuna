// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ArtistAdapter extends TypeAdapter<Artist> {
  @override
  final typeId = 0;

  @override
  Artist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artist(
      name: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Artist obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthorAdapter extends TypeAdapter<Author> {
  @override
  final typeId = 1;

  @override
  Author read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Author(
      name: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Author obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final typeId = 2;

  @override
  Chapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chapter(
      id: (fields[7] as num?)?.toInt(),
      link: fields[0] as String,
      title: fields[1] as String,
      released: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.link)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.released)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenreAdapter extends TypeAdapter<Genre> {
  @override
  final typeId = 3;

  @override
  Genre read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Genre(
      name: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Genre obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MangaAdapter extends TypeAdapter<Manga> {
  @override
  final typeId = 4;

  @override
  Manga read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Manga(
      id: (fields[19] as num?)?.toInt(),
      title: fields[0] as String,
      link: fields[1] as String,
      status: fields[2] as String?,
      image: fields[3] as String?,
      type: fields[4] as String?,
      lastChapter: fields[5] as String?,
      rating: (fields[7] as num?)?.toDouble(),
      followedBy: (fields[8] as num?)?.toInt(),
      synopsis: fields[9] as String?,
      serialization: fields[10] as String?,
      updatedOn: fields[11] as String?,
      totalChapters: (fields[12] as num?)?.toInt(),
      order: (fields[20] as num?)?.toInt(),
      authors:
          fields[13] == null ? const [] : (fields[13] as List).cast<Author>(),
      artists:
          fields[14] == null ? const [] : (fields[14] as List).cast<Artist>(),
      genres:
          fields[15] == null ? const [] : (fields[15] as List).cast<Genre>(),
      chapters:
          fields[16] == null ? const [] : (fields[16] as List).cast<Chapter>(),
    );
  }

  @override
  void write(BinaryWriter writer, Manga obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.lastChapter)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.followedBy)
      ..writeByte(9)
      ..write(obj.synopsis)
      ..writeByte(10)
      ..write(obj.serialization)
      ..writeByte(11)
      ..write(obj.updatedOn)
      ..writeByte(12)
      ..write(obj.totalChapters)
      ..writeByte(13)
      ..write(obj.authors)
      ..writeByte(14)
      ..write(obj.artists)
      ..writeByte(15)
      ..write(obj.genres)
      ..writeByte(16)
      ..write(obj.chapters)
      ..writeByte(19)
      ..write(obj.id)
      ..writeByte(20)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingStatusAdapter extends TypeAdapter<ReadingStatus> {
  @override
  final typeId = 5;

  @override
  ReadingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReadingStatus.notReading;
      case 1:
        return ReadingStatus.reading;
      case 2:
        return ReadingStatus.planning;
      case 3:
        return ReadingStatus.read;
      case 4:
        return ReadingStatus.postponed;
      case 5:
        return ReadingStatus.dropped;
      default:
        return ReadingStatus.notReading;
    }
  }

  @override
  void write(BinaryWriter writer, ReadingStatus obj) {
    switch (obj) {
      case ReadingStatus.notReading:
        writer.writeByte(0);
      case ReadingStatus.reading:
        writer.writeByte(1);
      case ReadingStatus.planning:
        writer.writeByte(2);
      case ReadingStatus.read:
        writer.writeByte(3);
      case ReadingStatus.postponed:
        writer.writeByte(4);
      case ReadingStatus.dropped:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserMangaAdapter extends TypeAdapter<UserManga> {
  @override
  final typeId = 6;

  @override
  UserManga read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserManga(
      mangaLink: fields[0] as String,
      lastChapterRead: fields[2] == null ? 0 : (fields[2] as num).toInt(),
      isFavorite: fields[1] == null ? false : fields[1] as bool,
      readingStatus: fields[3] == null
          ? ReadingStatus.notReading
          : fields[3] as ReadingStatus,
      lastPageReadByChapter:
          fields[4] == null ? const {} : (fields[4] as Map).cast<int, int>(),
      isReadByChapter:
          fields[5] == null ? const {} : (fields[5] as Map).cast<int, bool>(),
      downloadedImagePathsByChapter: fields[6] == null
          ? const {}
          : (fields[6] as Map).map((dynamic k, dynamic v) =>
              MapEntry((k as num).toInt(), (v as List).cast<String>())),
      lastReadTimestamp: fields[7] as DateTime?,
      chapterBookmarks: (fields[8] as Map?)?.cast<int, bool>(),
      totalReadingTimeInSeconds:
          fields[9] == null ? 0 : (fields[9] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UserManga obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.mangaLink)
      ..writeByte(1)
      ..write(obj.isFavorite)
      ..writeByte(2)
      ..write(obj.lastChapterRead)
      ..writeByte(3)
      ..write(obj.readingStatus)
      ..writeByte(4)
      ..write(obj.lastPageReadByChapter)
      ..writeByte(5)
      ..write(obj.isReadByChapter)
      ..writeByte(6)
      ..write(obj.downloadedImagePathsByChapter)
      ..writeByte(7)
      ..write(obj.lastReadTimestamp)
      ..writeByte(8)
      ..write(obj.chapterBookmarks)
      ..writeByte(9)
      ..write(obj.totalReadingTimeInSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMangaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChaptersDataModelAdapter extends TypeAdapter<ChaptersDataModel> {
  @override
  final typeId = 7;

  @override
  ChaptersDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChaptersDataModel(
      chapterId: fields[0] as String,
      imageUrls: (fields[1] as List).cast<String>(),
      imagePaths: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChaptersDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.imageUrls)
      ..writeByte(2)
      ..write(obj.imagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChaptersDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
