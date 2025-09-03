import 'package:flutter/material.dart';

enum ReadingStatus{
  notReading,
  reading,
  planning,
  read,
  postponed,
  dropped,
}

extension ReadingStatusExtension on ReadingStatus {
  String get name {
    switch (this) {
      case ReadingStatus.reading:
        return 'Reading';
      case ReadingStatus.planning:
        return 'Planning';
      case ReadingStatus.read:
        return 'Read';
      case ReadingStatus.postponed:
        return 'Postponed';
      case ReadingStatus.dropped:
        return 'Dropped';
      default:
        return 'Not Reading';
    }
  }

  Color get color {
    switch (this) {
      case ReadingStatus.reading:
        return Colors.green[800]!;
      case ReadingStatus.planning:
        return Colors.purple[700]!;
      case ReadingStatus.read:
        return Colors.lightBlue[900]!;
      case ReadingStatus.postponed:
        return Colors.yellow[800]!;
      case ReadingStatus.dropped:
        return Colors.red[800]!;
      default:
        return Colors.grey[500]!;
    }
  }
}