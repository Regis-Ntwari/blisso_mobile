import 'package:blisso_mobile/services/api_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';

class SnapshotService {
  Future<ApiResponse> fetchProfileSnapshots() async {
    String token = await SharedPreferencesService.getPreference('accessToken');
    final response =
        await ApiService().getData('fixtures/lifesnapshots/', token);

    return response;
  }
}
