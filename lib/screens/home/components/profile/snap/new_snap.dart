import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewSnap extends StateNotifier<List<int>> {
  NewSnap() : super([]);

  addSnapshot(int id) {
    if (state.contains(id)) {
      state.remove(id);
    } else {
      state = [...state, id];
    }
  }
}

final newSnapProviderImpl =
    StateNotifierProvider<NewSnap, List>((_) {
  return NewSnap();
});
