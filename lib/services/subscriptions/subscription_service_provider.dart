import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionServiceProvider extends StateNotifier<ApiState> {
  final SubscriptionService subscriptionService;

  SubscriptionServiceProvider({required this.subscriptionService})
      : super(ApiState());

  Future<void> getSubscriptionPlans() async {
    try {
      state = ApiState(isLoading: true);

      final response = await subscriptionService.getSubscriptionPlans();

      if (response.result == null) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        print(response.result);
        state = ApiState(isLoading: false, data: response.result);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final subscriptionServiceProviderImpl =
    StateNotifierProvider<SubscriptionServiceProvider, ApiState>((ref) {
  return SubscriptionServiceProvider(
      subscriptionService: SubscriptionService());
});
