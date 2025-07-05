import 'dart:math';

import 'package:blisso_mobile/services/message_requests/message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/models/short_story_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/stories/update_story_share_count_provider.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareStoryModal extends ConsumerStatefulWidget {
  ShortStoryModel story;
  ShareStoryModal({super.key, required this.story});

  @override
  ConsumerState<ShareStoryModal> createState() => _MessageRequestModalState();
}

class _MessageRequestModalState extends ConsumerState<ShareStoryModal> {
  TextEditingController searchController = TextEditingController();

  Future<void> getUsers() async {
    if (ref.read(messageRequestServiceProviderImpl).data == null) {
      final messageRequestRef =
          ref.read(messageRequestServiceProviderImpl.notifier);

      await messageRequestRef.mapApprovedUsers();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUsers();
    });
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

  Future<void> shareVideo(String receiver) async {
    try {
      final username = await SharedPreferencesService.getPreference('username');

      /**ChatMessageModel messageModel = ChatMessageModel(
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          parentId: stories[currentIndex]['id'].toString(),
          parentContent: 'Story',
          sender: username!,
          receiver: toUsername,
          action: 'created',
          content: replyController.text,
          isFileIncluded: false,
          createdAt: DateTime.now().toUtc().toIso8601String()); */
      ChatMessageModel messageModel = ChatMessageModel(
          sender: username,
          receiver: receiver,
          messageStatus: 'unseen',
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          contentFileType: 'Video_post',
          contentFileUrl: widget.story.profilePicture,
          content: 'Shared Video',
          parentContent: widget.story.id,
          isFileIncluded: false,
          createdAt: DateTime.now().toUtc().toIso8601String(),
          action: 'created');

      final messageRef = ref.read(webSocketNotifierProvider.notifier);
      messageRef.sendMessage(messageModel);
      Navigator.of(context).pop();
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    double height = MediaQuery.sizeOf(context).height;
    final messageRequestRef = ref.watch(messageRequestServiceProviderImpl);
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
                        decoration: const InputDecoration(
                          hintText: 'Search for users...',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60)),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: messageRequestRef.data.keys.length,
                    itemBuilder: (context, index) {
                      final usersList = messageRequestRef.data.keys.toList();
                      return InkWell(
                        onTap: () async{
                          final shareRef = ref.read(updateStoryShareCountProviderImpl.notifier);

                          await shareRef.updateStoryShareCount(int.parse(widget.story.id));
                          shareVideo(messageRequestRef.data[usersList[index]]
                              ['username']);
                        },
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  messageRequestRef.data[usersList[index]]
                                      ['profile_picture_url']),
                            ),
                            title: Text(messageRequestRef.data[usersList[index]]
                                ['fullname'])),
                      );
                    },
                  ))
                ],
              ),
      )),
    );
  }
}

void showShareVideoModal(BuildContext context, ShortStoryModel story) {
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
      return ShareStoryModal(
        story: story,
      );
    },
  );
}
