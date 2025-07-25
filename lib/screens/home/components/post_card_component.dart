import 'dart:math';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/message_request_modal.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCardComponent extends ConsumerStatefulWidget {
  final Map<String, dynamic> profile;
  const PostCardComponent({super.key, required this.profile});

  @override
  ConsumerState<PostCardComponent> createState() => _PostCardComponentState();
}

class _PostCardComponentState extends ConsumerState<PostCardComponent> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool isLoading = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  // Future<bool> checkIfChatExists(String username) async {
  //   final chatRef = ref.watch(chatServiceProviderImpl);
  //   if (chatRef.data == null || chatRef.data.isEmpty) {
  //     final chatRef = ref.read(chatServiceProviderImpl.notifier);
  //     await chatRef.getMessages();
  //   }

  //   for (var chat in chatRef.data) {
  //     if (chat.containsKey(username)) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

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

  Future<void> handleDMTap(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final targetUsername = widget.profile['user']['username'];

    try {
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
                  'full_name':
                      '${widget.profile['user']['first_name']} ${widget.profile['user']['last_name']}',
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
              iconColor: GlobalColors.primaryColor,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetProfile = ref.read(targetProfileProvider.notifier);
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SizedBox(
      child: Card(
          color: isLightTheme ? GlobalColors.whiteColor : Colors.black,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: () {
                targetProfile.updateTargetProfile(
                    TargetProfileModel.fromMap(widget.profile));
                Routemaster.of(context).push('/homepage/target-profile');
              },
              child: ListTile(
                  trailing: widget.profile['feeling_caption'] != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.profile['feeling_emojis'],
                                style: const TextStyle(fontSize: 24),
                              ),
                              Text(
                                widget.profile['feeling_caption'],
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        widget.profile['profile_picture_url']),
                  ),
                  contentPadding: const EdgeInsets.only(left: 5),
                  horizontalTitleGap: 10,
                  title: Row(
                    children: [
                      Text(widget.profile['nickname']),
                      Text(' - ${widget.profile['age']} years old')
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.location_on),
                      Text('${widget.profile['distance_annot']}'),
                    ],
                  )),
            ),
            SizedBox(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double imageHeight = constraints.maxWidth;
                  return SizedBox(
                    height: imageHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) {
                        setState(() {
                          _currentPage = value;
                        });
                      },
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: widget.profile['profile_images'][index]
                              ['image_url'],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: GlobalColors.primaryColor,
                            ),
                          ),
                        );
                      },
                      itemCount: widget.profile['profile_images'].length,
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.profile['profile_images'].length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentPage == index ? 12.0 : 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? GlobalColors.primaryColor
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: widget.profile['liked_this_profile'] || isLiked
                              ? const Icon(
                                  Icons.favorite,
                                  color: GlobalColors.primaryColor,
                                )
                              : const Icon(Icons.favorite_border),
                          onPressed: () async {
                            final likeRef =
                                ref.read(profileServiceProviderImpl.notifier);

                            final nickname =
                                await SharedPreferencesService.getPreference(
                                    'nickname');

                            setState(() {
                              if (widget.profile['liked_this_profile']) {
                                widget.profile['likes'] =
                                    widget.profile['likes'] - 1;
                                widget.profile['people_liked'].remove(nickname);
                              } else {
                                widget.profile['likes'] =
                                    widget.profile['likes'] + 1;
                                widget.profile['people_liked'].add(nickname);
                              }
                              widget.profile['liked_this_profile'] =
                                  !widget.profile['liked_this_profile'];
                              isLiked = !isLiked;
                            });

                            await likeRef.likeProfile(widget.profile['id']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            showMessageRequestModal(context, widget.profile);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 100,
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: GlobalColors.primaryColor,
                              ),
                            )
                          : ButtonComponent(
                              text: 'DM Me',
                              backgroundColor: GlobalColors.primaryColor,
                              foregroundColor: GlobalColors.whiteColor,
                              buttonHeight: 40,
                              buttonWidth: 100,
                              onTap: () => handleDMTap(context),
                            ),
                    )
                  ],
                )),
            widget.profile['likes'] == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10),
                    child: widget.profile['likes'] == 1
                        ? ExpandableTextComponent(
                            text:
                                'Liked by ${widget.profile['people_liked'][0]}')
                        : ExpandableTextComponent(
                            text:
                                'Liked by ${widget.profile['people_liked'][0]} and others'),
                  ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: widget.profile['target_lifesnapshots'].length > 0
                    ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: [
                            Text(
                                textAlign: TextAlign.start,
                                "${widget.profile['nickname']} is interested in "),
                            ...widget.profile['target_lifesnapshots']
                                .map((snap) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: GlobalColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.all(5),
                                      child: Text(snap['name']),
                                    ))
                          ],
                        ),
                    )
                    : const SizedBox.shrink()),
          ])),
    );
  }
}
