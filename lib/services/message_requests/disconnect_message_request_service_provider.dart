import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisconnectMessageRequestServiceProvider extends StateNotifier<ApiState> {
  final MessageRequestService messageRequestService;

  DisconnectMessageRequestServiceProvider({required this.messageRequestService})
      : super(ApiState());

  Future<void> sendDisconnectMessageRequest(String receiverUsername) async {
    try {
      state = ApiState(isLoading: true);
      final response =
          await messageRequestService.sendDisconnectionRequest(receiverUsername);

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

final disconnectMessageRequestServiceProviderImpl =
    StateNotifierProvider<DisconnectMessageRequestServiceProvider, ApiState>((ref) {
  return DisconnectMessageRequestServiceProvider(
      messageRequestService: MessageRequestService());
});
