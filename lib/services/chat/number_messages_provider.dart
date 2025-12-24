import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NumberMessagesProvider extends StateNotifier<bool> {
  final Ref ref;

  NumberMessagesProvider({required this.ref}) : super(false);

  Future<void> getNumberOfMessages() async {
    final messages = ref.watch(chatServiceProviderImpl);

    if (messages.data == null) {
      await ref.read(chatServiceProviderImpl.notifier).getMessages();
    }

    String? username = await SharedPreferencesService.getPreference('username');

    if (messages.data.isNotEmpty) {
      for (var message in messages.data) {
        List<dynamic> userMessages = message['messages'];
        if (userMessages[userMessages.length - 1]['message_status'] != 'seen' && userMessages[userMessages.length - 1]['sender'] != username!) {
          state = true;
          break;
        }
      }
    }
  }
}

final getNumberOfMessagesProvider = StateNotifierProvider<NumberMessagesProvider, bool>(
    (ref) => NumberMessagesProvider(ref: ref));
