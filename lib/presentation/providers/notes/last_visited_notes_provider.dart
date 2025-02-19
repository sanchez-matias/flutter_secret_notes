import 'package:flutter_secret_notes/domain/entities/note.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secret_notes/presentation/providers/repositories/repositories_providers.dart';

part 'last_visited_notes_provider.g.dart';

@Riverpod(keepAlive: true)
class LastVisitedNotes extends _$LastVisitedNotes {
  @override
  List<Note> build() {
    return [];
  }

  void _reorderItem(int id) {
    final itemIndex = state.indexWhere((note) => id == note.id);
    final itemsList = List<Note>.from(state).where((note) => note.id != id);
    
    state = [state[itemIndex], ...itemsList];
  }

  void getLastVisitedNotes() async {
    final notes = await ref.read(storageRepositoryProvider).getLastVisitedNotes();
    state = notes.reversed.toList();
  }

  Future<void> insertNote(int id) async {
    if (state.any((note) => note.id == id)) {
      _reorderItem(id);
      return;
    }

    if (state.length < 5) {
      await ref.read(storageRepositoryProvider).insertLastVisitedNotes(id);
      getLastVisitedNotes();
      return;
    }

    await ref.read(storageRepositoryProvider).deleteLastVisitedNote([state.last.id]);
    await ref.read(storageRepositoryProvider).insertLastVisitedNotes(id);
    getLastVisitedNotes();
  }

  Future<void> deleteNote(List<int> ids) async {
    await ref.read(storageRepositoryProvider).deleteLastVisitedNote(ids);

    getLastVisitedNotes();
  }

}