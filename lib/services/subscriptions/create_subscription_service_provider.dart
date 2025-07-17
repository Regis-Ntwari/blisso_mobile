import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateSubscriptionServiceProvider extends StateNotifier<ApiState> {
  final SubscriptionService subscriptionService;

  CreateSubscriptionServiceProvider({required this.subscriptionService})
      : super(ApiState());


  Future<void> createSubscription(Map<String, dynamic> subscription) async {
    try {
      state = ApiState(isLoading: true);

      final response =
          await subscriptionService.createSubscription(subscription);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final createSubscriptionProviderImpl =
    StateNotifierProvider<CreateSubscriptionServiceProvider, ApiState>((ref) {
  return CreateSubscriptionServiceProvider(
      subscriptionService: SubscriptionService());
});
