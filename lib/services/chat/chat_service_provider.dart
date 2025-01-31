import 'package:blisso_mobile/services/api_state.dart';
import 'package:blisso_mobile/services/chat/chat_service.dart';
import 'package:blisso_mobile/services/users/all_user_service_provider.dart';
import 'package:blisso_mobile/utils/status_codes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatServiceProvider extends StateNotifier<ApiState> {
  ChatServiceProvider(this.ref) : super(ApiState());

  final Ref ref;

  Future<void> getMessages() async {
    state = ApiState(isLoading: true);

    try {
      final allUsersState = ref.read(allUserServiceProviderImpl);

      dynamic users;
      if (allUsersState.data == null) {
        await ref.read(allUserServiceProviderImpl.notifier).getAllUsers();
        users = ref.read(allUserServiceProviderImpl).data;
      } else {
        users = allUsersState.data;
      }

      print(users);
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getAllMyMessages();

      if (!StatusCodes.codes.contains(messages.statusCode) ||
          !StatusCodes.codes.contains(users.statusCode)) {
        state = ApiState(isLoading: false, error: messages.errorMessage);
      } else {
        List<Map<String, List<dynamic>>> updatedMessages =
            messages.result.map((messageMap) {
          return messageMap.map((email, messageList) {
            String fullName = users.result[email]?["full_name"] ?? email;
            return MapEntry(fullName, messageList);
          });
        }).toList();

        state = ApiState(
            isLoading: false,
            data: updatedMessages,
            statusCode: messages.statusCode);
      }
    } catch (e) {
      state = ApiState(isLoading: false, error: e.toString());
    }
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final chatServiceProviderImpl =
    StateNotifierProvider<ChatServiceProvider, ApiState>(
  (ref) => ChatServiceProvider(ref),
);
