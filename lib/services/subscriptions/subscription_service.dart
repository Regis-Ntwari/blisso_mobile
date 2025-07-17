import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/models/initiate_payment_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class SubscriptionService {
  Future<ApiResponse> getSubscriptionPlans() async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().getData('/subscriptions/plans', token);

    return response;
  }

  Future<ApiResponse> createSubscription(
      Map<String, dynamic> subscription) async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().postData(
        endpoint: '/subscriptions/', body: subscription, token: token);

    return response;
  }

  Future<ApiResponse> initiatePayment(InitiatePaymentModel paymentModel) async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().postData(
        endpoint: '/payment/initiate-card-payment/',
        body: paymentModel.toMap(),
        token: token);

    return response;
  }

  Future<ApiResponse> verifyCardPayment(
      Map<String, dynamic> payment) async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().postData(
        endpoint: '/payment/initiate-card-auth-payment/',
        body: payment,
        token: token);

    return response;
  }

  Future<ApiResponse> validateOtp(Map<String, dynamic> payment) async{
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().postData(
        endpoint: '/payment/validate-payment/',
        body: payment,
        token: token);

    return response;
  }
}
