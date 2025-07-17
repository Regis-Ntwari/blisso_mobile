import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviousSubscriptionResponseProvider extends StateNotifier<Map<String, dynamic>>{

  PreviousSubscriptionResponseProvider() : super({});

  resetOptions() {
    state = {};
  }

  addWholeMap(Map<String, dynamic> data) {
    state = data;
  }
}

final previousSubscriptionResponseProviderImpl =
    StateNotifierProvider<PreviousSubscriptionResponseProvider, Map<String, dynamic>>((ref) {
  return PreviousSubscriptionResponseProvider();
});