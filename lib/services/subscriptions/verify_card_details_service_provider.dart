import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyCardDetailsServiceProvider extends StateNotifier<ApiState> {
  final SubscriptionService subscriptionService;

  VerifyCardDetailsServiceProvider({required this.subscriptionService})
      : super(ApiState());

  Future<void> verifyCardDetails(Map<String, dynamic> payment) async {
    print(payment);
    try {
      state = ApiState(isLoading: true);
      final response = await subscriptionService.verifyCardPayment(payment);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(
            isLoading: false,
            error: response.errorMessage,
            statusCode: response.statusCode);
      } else {
        state = ApiState(
            isLoading: false,
            data: response.result,
            statusCode: response.statusCode);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final verifyCardDetailsProviderImpl =
    StateNotifierProvider<VerifyCardDetailsServiceProvider, ApiState>((ref) {
  return VerifyCardDetailsServiceProvider(
      subscriptionService: SubscriptionService());
});
