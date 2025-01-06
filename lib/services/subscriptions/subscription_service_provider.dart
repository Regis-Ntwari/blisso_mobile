import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/models/initiate_payment_model.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionServiceProvider extends StateNotifier<ApiState> {
  final SubscriptionService subscriptionService;

  SubscriptionServiceProvider({required this.subscriptionService})
      : super(ApiState());

  Future<void> getSubscriptionPlans() async {
    try {
      state = ApiState(isLoading: true);

      final response = await subscriptionService.getSubscriptionPlans();

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage);
      } else {
        state = ApiState(isLoading: false, data: response.result);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }

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

  Future<void> initiatePayment(InitiatePaymentModel payment) async {
    try {
      state = ApiState(isLoading: true);
      final response = await subscriptionService.initiatePayment(payment);

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

  Future<void> verifyCardDetails(InitiatePaymentModel payment) async {
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

final subscriptionServiceProviderImpl =
    StateNotifierProvider<SubscriptionServiceProvider, ApiState>((ref) {
  return SubscriptionServiceProvider(
      subscriptionService: SubscriptionService());
});
