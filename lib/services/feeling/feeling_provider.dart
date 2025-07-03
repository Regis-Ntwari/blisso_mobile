import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeelingProvider extends StateNotifier<bool>{
  FeelingProvider() : super(true);

  updateState() {
    state = !state;
  }

}

final feelingProviderImpl =
    StateNotifierProvider<FeelingProvider, bool>(
        (ref) => FeelingProvider());