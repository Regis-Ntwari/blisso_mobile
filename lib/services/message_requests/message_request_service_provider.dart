import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/message_requests/Message_request_service.dart';
import 'package:blisso_mobile/services/models/api_response.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageRequestServiceProvider extends StateNotifier<ApiState> {
  final MessageRequestService messageRequestService;

  MessageRequestServiceProvider({required this.messageRequestService})
      : super(ApiState());

  Future<void> mapApprovedUsers() async {
    state = ApiState(isLoading: true);

    try {
      ApiResponse response;
      response = await messageRequestService.getApprovedUsers();
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
      state = ApiState(isLoading: true, error: e.toString());
    }
  }
}

final messageRequestServiceProviderImpl =
    StateNotifierProvider<MessageRequestServiceProvider, ApiState>((ref) {
  return MessageRequestServiceProvider(
      messageRequestService: MessageRequestService());
});
