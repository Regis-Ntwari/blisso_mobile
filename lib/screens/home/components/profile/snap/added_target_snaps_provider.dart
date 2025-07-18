import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedTargetSnapsProvider extends StateNotifier<List<int>> {
  AddedTargetSnapsProvider() : super([]);

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

final addedTargetSnapsProviderImpl =
    StateNotifierProvider<AddedTargetSnapsProvider, List>((_) {
  return AddedTargetSnapsProvider();
});
