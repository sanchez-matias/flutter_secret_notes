import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/config/plugins/images_plugin.dart';
import 'package:flutter_secret_notes/domain/domain.dart';
import 'package:flutter_secret_notes/presentation/providers/repositories/repositories_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_provider.g.dart';

@Riverpod(keepAlive: true)
class Notes extends _$Notes {
  int _page = 1;
  bool _isLoading = false;

  @override
  List<Note> build() {
    return []; 
  }

  void loadCurrentPage() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final notes = await ref.read(storageRepositoryProvider).getNotes(page: _page);
      state = notes;
    } catch (e) {
      // print(e);
    }

    _isLoading = false;
  }

  void loadNextPage() async {
    if (_isLoading) return;
    _page++;
    loadCurrentPage();
  }

  Future<int> addNewNote(Note note) async {
    final id = await ref.read(storageRepositoryProvider).createNote(note);
    loadCurrentPage();
    return id;
  }

  Future<void> deleteNote(List<int> ids) async {
    await ref.read(storageRepositoryProvider).deleteNotesById(ids);
    loadCurrentPage();
  }

  Future<void> editNote(Note newNoteContent) async {
    await ref.read(storageRepositoryProvider)
      .updateNoteById(newNoteContent);
    
    loadCurrentPage();
  }

  Future<void> pickFromCamera(int noteId) async {
    final path = await ImagesPlugin.pickImageFromCamera();
    if (path.isEmpty) return;

    final imageId = await ref.read(storageRepositoryProvider).addImage(path);
    await ref.read(storageRepositoryProvider).linkImage(noteId: noteId, imageId: imageId);
    ref.invalidate(getNoteProvider);
  }

  Future<void> pickFromGallery(int noteId) async {
    final path = await ImagesPlugin.pickImageFromGallery();
    if (path.isEmpty) return;

    final imageId = await ref.read(storageRepositoryProvider).addImage(path);
    await ref.read(storageRepositoryProvider).linkImage(noteId: noteId, imageId: imageId);
    ref.invalidate(getNoteProvider);
  }

  Future<void> deleteImage(CustomImage image) async {
    await ImagesPlugin.deleteImage(image.path);
    await ref.read(storageRepositoryProvider).removeImage(image.id);
    ref.invalidate(getNoteProvider);
  }
 }

@riverpod
FutureOr<Note?> getNote(Ref ref, int id) async {
  if (id <= 0) return null;

  final note = await ref.read(storageRepositoryProvider).getNoteById(id);
  return note;
}