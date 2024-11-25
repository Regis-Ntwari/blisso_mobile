import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetProvider extends StateNotifier<List<Map<String, dynamic>>> {
  TargetProvider() : super([{}]);

  addItemToList(Map<String, dynamic> interest, double scale) {
    if (scale <= 0) {
      state = [...state.where((element) => element['id'] != interest['id'])];
      return;
    } else {
      state = [
        ...state,
        {'id': interest['id'], 'scale': scale}
      ];
    }
  }
}

final targetProviderImpl =
    StateNotifierProvider<TargetProvider, List<Map<String, dynamic>>>(
        (ref) => TargetProvider());
