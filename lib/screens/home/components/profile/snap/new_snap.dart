import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewSnap extends StateNotifier<List<Map<String, dynamic>>> {
  NewSnap() : super([]);

  void addSnapshot(Map<String, dynamic> snap) {
    final exists = state.any((s) => s['id'] == snap['id']);

    if (exists) {
      state = state
          .where((s) => s['id'] != snap['id'])
          .toList(); 
    } else {
      state = [...state, snap]; 
    }
  }
}

final newSnapProviderImpl = StateNotifierProvider<NewSnap, List>((_) {
  return NewSnap();
});
