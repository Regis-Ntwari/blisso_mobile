import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class SubscriptionService {
  Future<ApiResponse> getSubscriptionPlans() async {
    String token = await SharedPreferencesService.getPreference('accessToken');

    final response = await ApiService().getData('/subscriptions/plans', token);

    return response;
  }
}
