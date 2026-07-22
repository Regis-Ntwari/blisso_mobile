import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/report/report_service.dart';

class ReportServiceProvider extends StateNotifier<ApiState> {
  final ReportService reportService;

  ReportServiceProvider({
    required this.reportService,
  }) : super(ApiState());

  Future<void> reportUser(String comment, String username) async {
    state = ApiState(isLoading: true);

    try {
      final response = await reportService.reportUser(comment, username);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(error: response.errorMessage, isLoading: false);
      } else {
        state = ApiState(data: response.result, isLoading: false);
      }
    } catch (e) {
      state = ApiState(error: e.toString(), isLoading: false);
    }
  }
}

final reportServiceProviderImpl =
    StateNotifierProvider<ReportServiceProvider, ApiState>((ref) {
  return ReportServiceProvider(reportService: ReportService());
});
