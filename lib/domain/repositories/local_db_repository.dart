import 'package:flutter_secret_notes/domain/entities/image.dart';
import 'package:flutter_secret_notes/domain/entities/note.dart';

abstract class LocalDbRepository {

  //* NOTES
  Future<void> createNote(Note note);

  Future<Note> getNoteById(int id);

  Future<List<Note>> getNotes({int page = 1});

  Future<void> updateNoteById(Note newNoteContent);
  
  Future<void> deleteNotesById(List<int> ids);

  Future<List<Note>> searchNote(String query);

  //* IMAGES
  Future<int> addImage(String path);

  Future<void> removeImage(int imageId);

  Future<List<CustomImage>> getImagesById(int noteId);

  Future<void> linkImage({required int noteId, required int imageId});
}
