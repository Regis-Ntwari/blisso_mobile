import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedSnapsProvider extends StateNotifier<List<dynamic>> {
  AddedSnapsProvider() : super([]);

  void addSnapshot(dynamic snap) {
    final exists = state.any((s) => s == snap['lifesnapshot_id']);

    if (exists) {
      return;
    } else {
      state = [...state, snap];
    }
  }

  void removeSnapshot(int id) {
    state = state.where((s) => s['lifesnapshot_id'] != id).toList();
  }

  bool exists(dynamic id) {
    for (var snap in state) {
      if (snap['lifesnapshot_id'] == id) {
        return true;
      }
    }
    return false;
  }

  reset() {
    state.clear();
  }
}

final addedSnapsProviderImpl =
    StateNotifierProvider<AddedSnapsProvider, List<dynamic>>((_) {
  return AddedSnapsProvider();
});
