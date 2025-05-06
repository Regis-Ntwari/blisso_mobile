import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetMessageRequestServiceProvider extends StateNotifier<ApiState> {
  final MessageRequestService messageRequestService;

  GetMessageRequestServiceProvider({required this.messageRequestService})
      : super(ApiState());

  Future<void> getMessageRequests() async {
    try {
      state = ApiState(isLoading: true);
      final response = await messageRequestService.getMessageRequests();

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

final getMessageRequestServiceProviderImpl =
    StateNotifierProvider<GetMessageRequestServiceProvider, ApiState>((ref) {
  return GetMessageRequestServiceProvider(
      messageRequestService: MessageRequestService());
});
