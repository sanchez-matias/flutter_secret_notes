import 'package:flutter_secret_notes/domain/entities/note.dart';

class NoteModel extends Note {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    super.mediaPaths,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['NoteID'] ?? -1,
        title: json['Title'] ?? 'No content',
        content: json['Content'] ?? 'No content',
        mediaPaths: json['paths'] ?? [],
      );
}
