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
  final ShortStoryModel story;
  ShareStoryModal({super.key, required this.story});

  @override
  ConsumerState<ShareStoryModal> createState() => _ShareStoryModalState();
}

class _ShareStoryModalState extends ConsumerState<ShareStoryModal> {
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

  Future<void> shareVideo(String receiver) async {
    try {
      final username = await SharedPreferencesService.getPreference('username');

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
                        onTap: () async{
                          final shareRef = ref.read(updateStoryShareCountProviderImpl.notifier);

                          await shareRef.updateStoryShareCount(int.parse(widget.story.id));
                          shareVideo(messageRequestRef.data[username]
                              ['username']);
                        },
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  messageRequestRef.data[username]
                                      ['profile_picture_url']),
                            ),
                            title: Text(messageRequestRef.data[username]
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
  story.shares = story.shares + 1;
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