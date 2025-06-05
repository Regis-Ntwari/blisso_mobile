import 'dart:math';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/screens/chat/attachments/message_request_modal.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';

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

  Future<bool> checkIfChatExists(String username) async {
    final chatRef = ref.watch(chatServiceProviderImpl);
    if (chatRef.data == null) {
      final chatRef = ref.read(chatServiceProviderImpl.notifier);
      await chatRef.getMessages();
    }

    for (var chat in chatRef.data) {
      print("checking if user exists in chat");
      print("${chatRef.data} ===");
      if (chat.containsKey(username)) {
        return true;
      }
    }
    return false;
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

  Future<void> handleDMTap(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final targetUsername = widget.profile['user']['username'];

    if (await checkIfChatExists(targetUsername)) {
      if (context.mounted) {
        Routemaster.of(context).push('/chat-detail/$targetUsername');
      }
    } else {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetProfile = ref.read(targetProfileProvider.notifier);
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return isLoading
        ? const LoadingScreen()
        : SizedBox(
            child: Card(
                color: isLightTheme ? GlobalColors.whiteColor : Colors.black,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          targetProfile.updateTargetProfile(
                              TargetProfileModel.fromMap(widget.profile));
                          Routemaster.of(context).push('/target-profile');
                        },
                        child: ListTile(
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
                                    imageUrl: widget.profile['profile_images']
                                        [index]['image_url'],
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: GlobalColors.primaryColor,
                                      ),
                                    ),
                                  );
                                },
                                itemCount:
                                    widget.profile['profile_images'].length,
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 10, left: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              widget.profile['profile_images'].length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 1.0, vertical: 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.favorite_border),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      showMessageRequestModal(
                                          context, widget.profile);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 100,
                                child: ButtonComponent(
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
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: widget.profile['target_lifesnapshots'].length >
                                  0
                              ? Text(
                                  textAlign: TextAlign.start,
                                  "${widget.profile['nickname']} is interested in ${widget.profile['target_lifesnapshots'].map((snapshot) => snapshot['name']).join(", ")}")
                              : const SizedBox.shrink()),
                    ])),
          );
  }
}
