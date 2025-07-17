import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/subscriptions/subscription_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtpServiceProvider extends StateNotifier<ApiState> {
  final SubscriptionService subscriptionService;

  VerifyOtpServiceProvider({required this.subscriptionService})
      : super(ApiState());

  Future<void> verifyOtp(Map<String, dynamic> payment) async {
    try {
      state = ApiState(isLoading: true);
      final response = await subscriptionService.validateOtp(payment);

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

final verifyOtpServiceProviderImpl =
    StateNotifierProvider<VerifyOtpServiceProvider, ApiState>((ref) {
  return VerifyOtpServiceProvider(
      subscriptionService: SubscriptionService());
});
