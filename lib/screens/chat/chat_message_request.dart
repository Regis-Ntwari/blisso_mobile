import 'package:blisso_mobile/services/message_requests/accept_message_request_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/get_message_request_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/reject_message_request_service_provider.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// Add this provider to check if user can view requests
final canViewRequestsProvider = StateProvider<bool>((ref) => false);

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

  Widget _buildPremiumOverlay({required Widget child, required String message}) {
    return Stack(
      children: [
        // Blurred content
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.grey.withOpacity(0.5),
            BlendMode.srcATop,
          ),
          child: child,
        ),
        // Upgrade prompt
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 50,
                      color: GlobalColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premium Feature',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to premium upgrade screen
                        // This would typically open a payment screen
                        print('Navigate to premium upgrade');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(8),
          height: 150,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                ListTile(
                  title: Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 100,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 120,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canViewRequests = ref.read(permissionProviderImpl)['can_view_message_requests'];
    
    if (!canViewRequests) {
      return _buildPremiumOverlay(
        child: _buildShimmerLoader(),
        message: 'Upgrade your plan to view message requests',
      );
    }

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
                title: Flexible(
                  child: Text(
                    request['requester_profile_name'] == null
                        ? ''
                        : 'You have received a message request from ${request['requester_profile_name']}',
                  ),
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