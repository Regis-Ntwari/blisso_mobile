import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChosenOptionsProvider extends StateNotifier<Map<String, dynamic>>{

  ChosenOptionsProvider() : super({});

  addOption(String key, dynamic value) {
    state = {...state, key: value};
  }

  resetOptions() {
    state = {};
  }

  addWholeMap(Map<String, dynamic> data) {
    state = data;
  }
}

final chosenOptionsProviderImpl =
    StateNotifierProvider<ChosenOptionsProvider, Map<String, dynamic>>((ref) {
  return ChosenOptionsProvider();
});