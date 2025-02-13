import 'package:flutter_secret_notes/domain/datasources/local_db_datasource.dart';
import 'package:flutter_secret_notes/domain/entities/image.dart';
import 'package:flutter_secret_notes/domain/entities/note.dart';
import 'package:flutter_secret_notes/domain/repositories/local_db_repository.dart';
import 'package:flutter_secret_notes/infrastructure/datasources/local_db_datasource_impl.dart';

class LocalDbRepositoryImpl extends LocalDbRepository {
  final LocalDbDatasource _datasource;

  LocalDbRepositoryImpl(LocalDbDatasource? datasource)
    : _datasource = datasource ?? LocalDbDatasourceImpl();

  //* NOTES

  @override
  Future<void> createNote(Note note) {
    return _datasource.createNote(note);
  }

  @override
  Future<void> deleteNotesById(List<int> ids) {
    return _datasource.deleteNotesById(ids);
  }

  @override
  Future<Note> getNoteById(int id) {
    return _datasource.getNoteById(id);
  }

  @override
  Future<List<Note>> getNotes({int page = 1}) {
    return _datasource.getNotes(page: page);
  }

  @override
  Future<void> updateNoteById(Note newNoteContent) {
    return _datasource.updateNoteById(newNoteContent);
  }

  @override
  Future<List<Note>> searchNote(String query) {
    return _datasource.searchNote(query);
  }

  //* IMAGES
  
  @override
  Future<int> addImage(String path) {
    return _datasource.addImage(path);
  }

  @override
  Future<void> removeImage(int imageId) {
    return _datasource.removeImage(imageId);
  }
  
  @override
  Future<List<CustomImage>> getImagesById(int noteId) {
    return _datasource.getImagesById(noteId);
  }
  
  @override
  Future<void> linkImage({required int noteId, required int imageId}) {
    return _datasource.linkImage(noteId: noteId, imageId: imageId);
  }
  
}
