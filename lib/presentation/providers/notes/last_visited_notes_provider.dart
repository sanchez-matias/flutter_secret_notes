import 'package:flutter_secret_notes/domain/entities/note.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_visited_notes_provider.g.dart';

@riverpod
class LastVisitedNotes extends _$LastVisitedNotes {
  @override
  List<Note> build() {
    return [];
  }

  Future<void> getLastVisitedNotes() async {
    // TODO: obtener las ultimas notas desde la base de datos
  }

  void setNewNote(Note note) {
    // TODO: usar el parametro para agregar una nueva nota a la lista, guardar la nueva lista y obtenerla
  }

}