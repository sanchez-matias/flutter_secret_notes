import 'package:flutter_secret_notes/domain/domain.dart';

class Note {
  final int id;
  final String title;
  final String content;
  final List<String> tags;
  final List<CustomImage> mediaPaths;

  bool get isEmpty => title.isEmpty && content.isEmpty && mediaPaths.isEmpty;

  bool get hasMedia => mediaPaths.isNotEmpty;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.mediaPaths = const [],
  });
}
