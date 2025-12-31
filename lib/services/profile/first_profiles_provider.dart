import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirstProfilesProvider extends StateNotifier<bool>{

  FirstProfilesProvider() : super(false);

  void updateProfile() {
    state = true;
  }
}

final firstProfileProviderImpl = StateNotifierProvider<FirstProfilesProvider, bool>((_) {
  return FirstProfilesProvider();
});