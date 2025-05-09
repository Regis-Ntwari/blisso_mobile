import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RejectMessageRequestServiceProvider extends StateNotifier<ApiState> {
  final MessageRequestService messageRequestService;

  RejectMessageRequestServiceProvider({required this.messageRequestService})
      : super(ApiState());

  Future<void> rejectMessageRequest(int id) async {
    try {
      state = ApiState(isLoading: true);
      final response = await messageRequestService.rejectMessageRequest(id);

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

final rejectMessageRequestServiceProviderImpl =
    StateNotifierProvider<RejectMessageRequestServiceProvider, ApiState>((ref) {
  return RejectMessageRequestServiceProvider(
      messageRequestService: MessageRequestService());
});
