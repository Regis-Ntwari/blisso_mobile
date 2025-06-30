import 'dart:convert';
import 'dart:math';

import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';
import 'package:blisso_mobile/services/stories/stories_service_provider.dart';

class ViewStoryComponent extends ConsumerStatefulWidget {
  const ViewStoryComponent({super.key});

  @override
  ConsumerState<ViewStoryComponent> createState() => _ViewStoryPageState();
}

class _ViewStoryPageState extends ConsumerState<ViewStoryComponent> {
  int currentIndex = 0;
  VideoPlayerController? _videoController;
  List<Map<String, dynamic>> stories = [];
  bool _isDataLoaded = false;
  String nickname = '';
  bool isLiked = false;
  bool isSendingReply = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNickname();
      getMyUsername();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadData();
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  void _loadData() {
    final queryParams = Routemaster.of(context).currentRoute.queryParameters;
    String? encodedData = queryParams['data'];

    if (encodedData != null) {
      setState(() {
        stories = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
      });
      _loadStory();
    }
  }

  void _loadStory() {
    if (stories[currentIndex]['post_type'] == 'VIDEO') {
      _videoController = VideoPlayerController.networkUrl(
          Uri.parse(stories[currentIndex]['post_file_url']))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  Future<void> getNickname() async {
    await SharedPreferencesService.getPreference('nickname').then((nick) {
      setState(() {
        nickname = nick;
      });
    });
  }

  void _nextStory() {
    if (currentIndex < stories.length - 1) {
      setState(() {
        currentIndex++;
        _videoController?.dispose();
        _loadStory();
      });
    } else {
      Navigator.pop(context); // Close story view when finished
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _videoController?.dispose();
        _loadStory();
      });
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

  String? username;
  Future<void> getMyUsername() async {
    await SharedPreferencesService.getPreference('username').then((use) {
      setState(() {
        username = use;
      });
    });
  }

  void sendReply(String toUsername) async {
    setState(() {
      isSendingReply = true;
    });
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
                parentId: stories[currentIndex]['id'].toString(),
                parentContent: 'Story',
                contentFileType: stories[currentIndex]['id'].toString(),
                sender: username!,
                receiver: toUsername,
                action: 'created',
                content: replyController.text,
                isFileIncluded: false,
                createdAt: DateTime.now().toUtc().toIso8601String());

            final messageRef = ref.read(webSocketNotifierProvider.notifier);
            messageRef.sendMessage(messageModel);

            setState(() {
              replyController.clear();
              isSendingReply = false;
            });
          } catch (e) {
            setState(() {
              isSendingReply = false;
            });
          }
        } else if (messageRequestResponse.statusCode == 201) {
          setState(() {
            isSendingReply = false;
          });
          showPopupComponent(
              context: context,
              icon: Icons.verified,
              iconColor: Colors.green[800],
              message: 'Message request sent to $username!');
        } else {
          setState(() {
            isSendingReply = false;
          });
          showPopupComponent(
            context: context,
            icon: Icons.error,
            iconColor: Colors.red,
            message: messageRequestResponse.error!,
          );
        }
      }
    }

    // try {
    //   ChatMessageModel messageModel = ChatMessageModel(
    //       messageId: generate12ByteHexFromTimestamp(DateTime.now()),
    //       parentId: stories[currentIndex]['id'].toString(),
    //       parentContent: 'Story',
    //       contentFileType: stories[currentIndex]['id'],
    //       sender: username!,
    //       receiver: toUsername,
    //       action: 'created',
    //       content: replyController.text,
    //       isFileIncluded: false,
    //       createdAt: DateTime.now().toUtc().toIso8601String());

    //   final messageRef = ref.read(webSocketNotifierProvider.notifier);
    //   messageRef.sendMessage(messageModel);

    //   setState(() {
    //     replyController.clear();
    //     isSendingReply = false;
    //   });
    // } catch (e) {
    //   setState(() {
    //     isSendingReply = false;
    //   });
    // }
  }

  TextEditingController replyController = TextEditingController();

  void _handleLike() {
    final storyId = stories[currentIndex]['id'];
    if (storyId != null) {
      ref.read(storiesServiceProviderImpl.notifier).likeStory(storyId);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  bool isProfileLoading = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  /*try {
      final messageRequestRef =
          ref.read(addMessageRequestServiceProviderImpl.notifier);
      await messageRequestRef.sendMessageRequest(targetUsername);

      final messageRequestResponse =
          ref.read(addMessageRequestServiceProviderImpl);

      if (messageRequestResponse.error == null) {
        if (context.mounted) {
          // Show success popup
          if (messageRequestResponse.statusCode == 200) {
            final chatRef = ref.read(chatServiceProviderImpl);
            if (chatRef.data == null || chatRef.data.isEmpty) {
              final chatRef = ref.read(chatServiceProviderImpl.notifier);
              await chatRef.getMessages();
            }
            final chatsRef = ref.read(chatServiceProviderImpl);
            for (var chat in chatsRef.data) {
              if (chat['username'] == targetUsername) {
                final chatDetailsRef =
                    ref.read(getChatDetailsProviderImpl.notifier);
                chatDetailsRef.updateChatDetails({
                  'username': targetUsername,
                  'profile_picture': widget.profile['profile_picture_url'],
                  'full_name': '${widget.profile['user']['first_name']} ${widget.profile['user']['last_name']}',
                  'nickname': widget.profile['nickname'],
                  'messages': chat['messages']
                });
              }
            }
            setState(() {
              isLoading = false;
            });
            Routemaster.of(context).push('/chat-detail/$targetUsername');
          } else if (messageRequestResponse.statusCode == 201) {
            setState(() {
              isLoading = false;
            });
            showPopupComponent(
                context: context,
                icon: Icons.verified,
                iconColor: Colors.green[800],
                message:
                    'Message request sent to ${widget.profile['nickname']}!');
          } else {
            setState(() {
              isLoading = false;
            });
            showPopupComponent(
              context: context,
              icon: Icons.error,
              iconColor: Colors.red,
              message: messageRequestResponse.error!,
            );
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        showPopupComponent(
            context: context,
            icon: Icons.error,
            message: messageRequestResponse.error!);
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
        // Show error popup
        showPopupComponent(
          context: context,
          icon: Icons.error,
          iconColor: Colors.red,
          message: 'Failed to send message request: ${e.toString()}',
        );
      }
    } */

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isDataLoaded
          ? const Center(
              child: CircularProgressIndicator(
                color: GlobalColors.primaryColor,
              ),
            )
          : GestureDetector(
              onTapUp: (details) {
                if (details.globalPosition.dx <
                    MediaQuery.of(context).size.width / 2) {
                  _previousStory();
                } else {
                  _nextStory();
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: stories[currentIndex]['post_type'] == 'IMAGE'
                        ? CachedNetworkImage(
                            imageUrl: stories[currentIndex]['post_file_url'],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: GlobalColors.primaryColor,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          )
                        : _videoController != null &&
                                _videoController!.value.isInitialized
                            ? VideoPlayer(_videoController!)
                            : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 5,
                                  color: GlobalColors.primaryColor,
                                ),
                              ),
                  ),
                  Positioned(
                    top: 50,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 130,
                    left: 10,
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          isProfileLoading = true;
                        });
                        try {
                          final profileRef =
                              ref.read(anyProfileServiceProviderImpl.notifier);
                          await profileRef
                              .getAnyProfile(stories[currentIndex]['username']);

                          final targetProfile =
                              ref.read(targetProfileProvider.notifier);
                          final profileData =
                              ref.read(anyProfileServiceProviderImpl);

                          targetProfile.updateTargetProfile(
                              TargetProfileModel.fromMap(
                                  profileData.data as Map<String, dynamic>));
                          setState(() {
                            isProfileLoading = false;
                          });
                          if (mounted) {
                            Routemaster.of(context)
                                .push('/homepage/target-profile');
                          }
                        } catch (e) {
                          showSnackBar(context, 'Failed to load profile');
                        }
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                              stories[currentIndex]['profile_picture_uri'] ??
                                  '',
                            ),
                            onBackgroundImageError: (_, __) {},
                            child: stories[currentIndex]
                                        ['profile_picture_uri'] ==
                                    null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stories[currentIndex]['nickname'] == nickname
                                    ? 'My Story'
                                    : stories[currentIndex]['nickname'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  isSendingReply
                      ? Center(
                          child: Container(
                            width: 120,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[800]),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: const Text(
                                  'Sending...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Positioned(
                    bottom: 100,
                    left: 10,
                    right: 10,
                    child: stories[currentIndex]['caption'] != null
                        ? Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 20,
                            ),
                            child: 
                                Center(
                                  child: ExpandableTextComponent(
                                    text: stories[currentIndex]['caption'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3.0,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Positioned(
                    top: 40,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: List.generate(stories.length, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: index <= currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  stories[currentIndex]['nickname'] != nickname
                      ? Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Stack(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Like button
                                    IconButton(
                                      onPressed: _handleLike,
                                      icon: Icon(
                                        stories[currentIndex]
                                                    ['liked_this_story'] ||
                                                isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: stories[currentIndex]
                                                    ['liked_this_story'] ||
                                                isLiked
                                            ? GlobalColors.primaryColor
                                            : Colors.white,
                                      ),
                                    ),
                                    // Reply Text Field in the middle
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          color: isLightTheme
                                              ? Colors.grey[900]
                                              : Colors.grey[200],
                                        ),
                                        child: TextField(
                                          controller: replyController,
                                          style: TextStyle(
                                              color: isLightTheme
                                                  ? Colors.black
                                                  : Colors.white),
                                          decoration: const InputDecoration(
                                            hintText: 'Reply...',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 1,
                                                    horizontal: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(60)),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Share button
                                    IconButton(
                                      onPressed: () {
                                        if (replyController.text.isNotEmpty) {
                                          sendReply(stories[currentIndex]
                                              ['username']);
                                        }
                                      },
                                      icon: const Icon(Icons.send,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Positioned(
                          left: 0,
                          bottom: 10,
                          right: 0,
                          child: InkWell(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${stories[currentIndex]['likes'] ?? 0}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.favorite,
                                  size: 20,
                                ),
                              ],
                            ),
                          )),
                  isProfileLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
    );
  }
}
