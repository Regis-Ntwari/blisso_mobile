import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewTargetSnap extends StateNotifier<List<Map<String, dynamic>>> {
  NewTargetSnap() : super([]);

  addSnapshot(dynamic snap) {
    int check = 0;
    for (var s in state) {
      if (s['id'] == snap['id']) {
        state.remove(s);
        check = 1;
        break;
      }
    }

    if (check == 0) {
      state = [...state, snap];
    }
  }
}

final newTargetSnapProviderImpl = StateNotifierProvider<NewTargetSnap, List>((_) {
  return NewTargetSnap();
});
