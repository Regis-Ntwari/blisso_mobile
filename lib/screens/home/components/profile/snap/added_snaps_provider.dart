import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedSnapsProvider extends StateNotifier<List<int>> {
  AddedSnapsProvider() : super([]);

  addSnapshot(int id) {
    if (state.contains(id)) {
      state.remove(id);
    } else {
      state = [...state, id];
    }
  }

  reset() {
    state = [];
  }
}

final addedSnapsProviderImpl =
    StateNotifierProvider<AddedSnapsProvider, List>((_) {
  return AddedSnapsProvider();
});
