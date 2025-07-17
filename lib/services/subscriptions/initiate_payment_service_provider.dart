import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/models/initiate_payment_model.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitiatePaymentServiceProvider extends StateNotifier<ApiState> {
  final SubscriptionService subscriptionService;

  InitiatePaymentServiceProvider({required this.subscriptionService})
      : super(ApiState());
  Future<void> initiatePayment(InitiatePaymentModel payment) async {
    try {
      state = ApiState(isLoading: true);
      final response = await subscriptionService.initiatePayment(payment);
      print(response);

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

final initiatePaymentServiceProviderImpl =
    StateNotifierProvider<InitiatePaymentServiceProvider, ApiState>((ref) {
  return InitiatePaymentServiceProvider(
      subscriptionService: SubscriptionService());
});
