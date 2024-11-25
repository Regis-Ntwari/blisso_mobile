import 'package:flutter_riverpod/flutter_riverpod.dart';

class MySnapshotsProvider extends StateNotifier<List<int>> {
  MySnapshotsProvider() : super([]);

  void toggleInterest(Map<String, dynamic> interest) {
    if (state.contains(interest['id'])) {
      state = [...state.where((id) => id != interest['id'])];
    } else {
      state = [...state, interest['id']];
    }
  }

  bool containsInterest(Map<String, dynamic> interest) {
    return state.contains(interest['id']);
  }
}

final mySnapshotsProviderImpl =
    StateNotifierProvider<MySnapshotsProvider, List<int>>(
        (ref) => MySnapshotsProvider());
