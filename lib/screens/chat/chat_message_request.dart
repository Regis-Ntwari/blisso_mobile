import 'package:blisso_mobile/services/message_requests/accept_message_request_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/get_message_request_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/reject_message_request_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatMessageRequest extends ConsumerStatefulWidget {
  const ChatMessageRequest({super.key});

  @override
  ConsumerState<ChatMessageRequest> createState() => _ChatMessageRequestState();
}

class _ChatMessageRequestState extends ConsumerState<ChatMessageRequest> {
  String formatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    final DateTime now = DateTime.now();
    final DateFormat timeFormat = DateFormat("hh:mm");

    bool isSameDay(DateTime date1, DateTime date2) =>
        date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;

    if (isSameDay(dateTime, now)) {
      return 'Today, ${timeFormat.format(dateTime)}';
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(dateTime, yesterday)) {
      return 'Yesterday, ${timeFormat.format(dateTime)}';
    }

    return DateFormat("dd/MM/yyyy, hh:mm").format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(getMessageRequestServiceProviderImpl.notifier)
          .getMessageRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageRequests = ref.watch(getMessageRequestServiceProviderImpl);
    final acceptMessageRequest =
        ref.watch(acceptMessageRequestServiceProviderImpl);
    final denyMessageRequest =
        ref.watch(rejectMessageRequestServiceProviderImpl);

    if (messageRequests.isLoading ||
        acceptMessageRequest.isLoading ||
        denyMessageRequest.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: GlobalColors.primaryColor),
      );
    }

    if (messageRequests.error != null) {
      return Center(
        child: Text('An error occurred: ${messageRequests.error}'),
      );
    }

    final List<dynamic> requests = messageRequests.data ?? [];

    if (requests.isEmpty) {
      return const Center(child: Text('No message requests yet'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          margin: const EdgeInsets.all(3),
          height: 150,
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(request['requester_profile_name'] == null
                        ? ''
                        : 'You have received a message request from ${request['request_profile_name']}'),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      final acceptRef = ref.read(
                          acceptMessageRequestServiceProviderImpl.notifier);

                      await acceptRef.acceptMessageRequest(request['id']);

                      ref
                          .read(getMessageRequestServiceProviderImpl.notifier)
                          .getMessageRequests();
                    },
                    icon: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Accept'),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final rejectRef = ref.read(
                          rejectMessageRequestServiceProviderImpl.notifier);

                      await rejectRef.rejectMessageRequest(request['id']);

                      ref
                          .read(getMessageRequestServiceProviderImpl.notifier)
                          .getMessageRequests();
                    },
                    icon: const Row(
                      children: [
                        Icon(Icons.close, color: Colors.red),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Reject'),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  formatDate(request['request_date']),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const Divider()
            ],
          ),
        );
      },
    );
  }
}
