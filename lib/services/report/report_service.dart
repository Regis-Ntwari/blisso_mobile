import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class ReportService {


  Future<ApiResponse> reportUser(String comment, String username) async {
    final accessToken =
        await SharedPreferencesService.getPreference('accessToken');

    return ApiService().postData(
      endpoint: 'blisso_administration/mobile-user-reports/',
      token: accessToken,
      body: {'reported_user': username, 'report_description': comment},
    );
  }
}
