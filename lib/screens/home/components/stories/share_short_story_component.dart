import 'dart:math';

import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/message_requests/message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareShortStoryComponent extends ConsumerStatefulWidget {
  final int storyId;
  ShareShortStoryComponent({super.key, required this.storyId});

  @override
  ConsumerState<ShareShortStoryComponent> createState() =>
      _ShareStoryModalState();
}

class _ShareStoryModalState extends ConsumerState<ShareShortStoryComponent> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUsers();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  void shareStory(String toUsername) async {
    String username = await SharedPreferencesService.getPreference('username');
    final messageRequestRef =
        ref.read(addMessageRequestServiceProviderImpl.notifier);
    await messageRequestRef.sendMessageRequest(toUsername);

    final messageRequestResponse =
        ref.read(addMessageRequestServiceProviderImpl);

    if (messageRequestResponse.error == null) {
      if (context.mounted) {
        if (messageRequestResponse.statusCode == 200) {
          final chatRef = ref.read(chatServiceProviderImpl);
          if (chatRef.data == null || chatRef.data.isEmpty) {
            final chatRef = ref.read(chatServiceProviderImpl.notifier);
            await chatRef.getMessages();
          }
          try {
            ChatMessageModel messageModel = ChatMessageModel(
                messageId: generate12ByteHexFromTimestamp(DateTime.now()),
                parentId: widget.storyId.toString(),
                parentContent: 'Story',
                contentFileType: widget.storyId.toString(),
                sender: username,
                receiver: toUsername,
                messageStatus: 'unseen',
                action: 'created',
                content: 'Story Shared',
                isFileIncluded: false,
                createdAt: DateTime.now().toUtc().toIso8601String());

            final messageRef = ref.read(webSocketNotifierProvider.notifier);
            messageRef.sendMessage(messageModel);
          } catch (e) {}
        } else if (messageRequestResponse.statusCode == 201) {
          showPopupComponent(
              context: context,
              icon: Icons.verified,
              iconColor: Colors.green[800],
              message: 'Message request sent');
        } else {
          showPopupComponent(
            context: context,
            icon: Icons.error,
            iconColor: Colors.red,
            message: messageRequestResponse.error!,
          );
        }
      }
    }
  }

  Future<void> getUsers() async {
    if (ref.read(messageRequestServiceProviderImpl).data == null) {
      final messageRequestRef =
          ref.read(messageRequestServiceProviderImpl.notifier);

      await messageRequestRef.mapApprovedUsers();
    }
  }

  String generate12ByteHexFromTimestamp(DateTime dateTime) {
    // Convert DateTime to Unix timestamp in milliseconds
    int timestamp = dateTime.millisecondsSinceEpoch;

    // Convert timestamp (8 bytes) to hex
    String hexTimestamp = timestamp.toRadixString(16).padLeft(16, '0');

    // Generate 4 random bytes (8 hex characters)
    final random = Random();
    String randomHex = List.generate(
        4, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

    // Combine timestamp + random bytes (12 bytes = 24 hex characters)
    return hexTimestamp + randomHex;
  }

  List<String> _getFilteredUsers(Map<String, dynamic> usersData) {
    if (searchQuery.isEmpty) {
      return usersData.keys.toList();
    }

    return usersData.keys.where((username) {
      final user = usersData[username];
      final fullName = user['fullname']?.toString().toLowerCase() ?? '';
      final nickname = user['nickname']?.toString().toLowerCase() ?? '';

      return fullName.contains(searchQuery) ||
          nickname.contains(searchQuery) ||
          username.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    double height = MediaQuery.sizeOf(context).height;
    final messageRequestRef = ref.watch(messageRequestServiceProviderImpl);

    final filteredUsers = _getFilteredUsers(messageRequestRef.data ?? {});

    return SizedBox(
      height: height * 0.9,
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: messageRequestRef.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: GlobalColors.primaryColor,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close)),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 10, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        color:
                            isLightTheme ? Colors.grey[100] : Colors.grey[900],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for users...',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60)),
                              borderSide: BorderSide.none),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: isLightTheme
                                          ? Colors.grey[600]
                                          : Colors.grey[400]),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: filteredUsers.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? 'No users available'
                                    : 'No users found for "$searchQuery"',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final username = filteredUsers[index];
                                return InkWell(
                                  onTap: () async {
                                    shareStory(username);
                                  },
                                  child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                messageRequestRef.data[username]
                                                    ['profile_picture_url']),
                                      ),
                                      title: Text(messageRequestRef
                                          .data[username]['fullname'])),
                                );
                              },
                            ))
                ],
              ),
      )),
    );
  }
}

void showShareShortStoryModal(BuildContext context, int storyId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black,
    builder: (BuildContext context) {
      return ShareShortStoryComponent(
        storyId: storyId,
      );
    },
  );
}
