import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMessageRequestServiceProvider extends StateNotifier<ApiState> {
  final MessageRequestService messageRequestService;

  AddMessageRequestServiceProvider({required this.messageRequestService})
      : super(ApiState());

  Future<void> sendMessageRequest(String receiverUsername) async {
    try {
      state = ApiState(isLoading: true);
      final response =
          await messageRequestService.sendMessageRequest(receiverUsername);

      if (!StatusCodes.codes.contains(response.statusCode)) {
        state = ApiState(isLoading: false, error: response.errorMessage, statusCode: response.statusCode);
      } else {
        state = ApiState(isLoading: false, data: response.result, statusCode: response.statusCode);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final addMessageRequestServiceProviderImpl =
    StateNotifierProvider<AddMessageRequestServiceProvider, ApiState>((ref) {
  return AddMessageRequestServiceProvider(
      messageRequestService: MessageRequestService());
});
