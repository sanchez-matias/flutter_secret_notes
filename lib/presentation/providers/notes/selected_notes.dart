import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_notes.g.dart';

@riverpod
class SelectedNotes extends _$SelectedNotes {
  @override
  Set<int> build() {
    return {};
  }

  void addId(int id) {
    state = {...state, id};
  }

  void remove(int id) {
    state = {...state}..remove(id);
  }

  void removeAll() {
    state = {};
  }
}
