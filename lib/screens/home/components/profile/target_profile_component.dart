import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:blisso_mobile/services/chat/chat_service_provider.dart';
import 'package:blisso_mobile/services/chat/get_chat_details_provider.dart';
import 'package:blisso_mobile/services/message_requests/add_message_request_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/video-post/video_post_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

class TargetProfileComponent extends ConsumerStatefulWidget {
  const TargetProfileComponent({super.key});

  @override
  ConsumerState<TargetProfileComponent> createState() =>
      _TargetProfileComponentState();
}

class _TargetProfileComponentState
    extends ConsumerState<TargetProfileComponent> {
  String expandedField = '';
  bool isLoading = false;

  Future<bool> checkIfChatExists(String username) async {
    final chatRef = ref.read(chatServiceProviderImpl);
    if (chatRef.data == null) {
      final chatRef = ref.read(chatServiceProviderImpl.notifier);
      await chatRef.getMessages();
    }

    for (var chat in chatRef.data) {
      if (chat.containsKey(username)) {
        return true;
      }
    }
    return false;
  }

  Future<void> handleDMTap(BuildContext context) async {
    final targetProfile = ref.watch(targetProfileProvider);
    final targetUsername = targetProfile.user!['username'];
    setState(() {
      isLoading = true;
    });

    // if (await checkIfChatExists(targetUsername)) {
    //   if (context.mounted) {
    //     Routemaster.of(context).push('/chat-detail/$targetUsername');
    //   }
    // }
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
                  'profile_picture': targetProfile.profilePictureUri,
                  'full_name':
                      '${targetProfile.user!['first_name']} ${targetProfile.user!['last_name']}',
                  'nickname': targetProfile.nickname,
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
                message: 'Message request sent to ${targetProfile.nickname}!');
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetProfile = ref.watch(targetProfileProvider);
      ref
          .read(videoPostServiceProviderImpl.notifier)
          .getTargetVideos(targetProfile.user!['username']);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextScaler scaler = MediaQuery.textScalerOf(context);
    final targetProfile = ref.watch(targetProfileProvider);
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final videoState = ref.watch(videoPostServiceProviderImpl);
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        leading: InkWell(
          //onTap: () => Routemaster.of(context).push('/homepage'),
          onTap: () => Routemaster.of(context).pop(),
          child: const Icon(Icons.keyboard_arrow_left),
        ),
        centerTitle: true,
        title: Text(
          '${targetProfile.nickname}',
          style: TextStyle(
              color: GlobalColors.primaryColor, fontSize: scaler.scale(24)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: width * 0.85,
                            width: width * 0.85,
                            child: InkWell(
                              onTap: () => Routemaster.of(context).push(
                                  '/homepage/target-profile/image-viewer?url=${targetProfile.profilePictureUri!}&isMe=false&isProfilePic=false'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                    imageUrl: targetProfile.profilePictureUri!,
                                    placeholder: (context, url) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: GlobalColors.primaryColor,
                                        ),
                                      );
                                    },
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.09,
                            width: width * 0.85,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${targetProfile.user!['first_name'].toString().toUpperCase()} ${targetProfile.user!['last_name'].toString().toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: scaler.scale(24),
                                      ),
                                    ),
                                    targetProfile.feeling == null
                                        ? const SizedBox.shrink()
                                        : Text(
                                            'Feeling ${targetProfile.feeling!}',
                                            style: TextStyle(
                                                color: GlobalColors
                                                    .secondaryColor),
                                          )
                                  ]),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.15,
                            width: width * 0.85,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date of Birth',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(DateFormat('MMMM d, y').format(
                                            DateTime.parse(targetProfile.dob!)))
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gender',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(
                                            targetProfile.gender!.toUpperCase())
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Marital Status',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(targetProfile.maritalStatus!.toUpperCase())
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Home Address',
                                          style: TextStyle(
                                              color:
                                                  GlobalColors.secondaryColor),
                                        ),
                                        Text(targetProfile.homeAddress!
                                            .toUpperCase())
                                      ],
                                    )
                                  ],
                                ),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceEvenly,
                                //   children: [
                                //     Wrap(
                                //       children: [
                                //         const Icon(Icons.join_right_rounded),
                                //         Text('${targetProfile.maritalStatus}')
                                //       ],
                                //     ),
                                //     Wrap(
                                //       children: [
                                //         const Icon(Icons.language),
                                //         Text('${targetProfile.lang}')
                                //       ],
                                //     )
                                //   ],
                                // ),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceEvenly,
                                //   children: [
                                //     Wrap(children: [
                                //       const Icon(Icons.home),
                                //       targetProfile.homeAddress == '' ||
                                //               targetProfile.homeAddress == null
                                //           ? const Text('Not Said')
                                //           : Text('${targetProfile.homeAddress}')
                                //     ]),
                                //     Wrap(children: [
                                //       const Icon(Icons.check_circle),
                                //       Text('${targetProfile.showMe}')
                                //     ]),
                                //   ],
                                // )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: ButtonComponent(
                        text: isLoading ? 'Loading...' : 'DM Me',
                        backgroundColor: GlobalColors.primaryColor,
                        foregroundColor: GlobalColors.lightBackgroundColor,
                        onTap: isLoading ? () {} : () => handleDMTap(context)),
                  ),
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    SizedBox(
                        height: 250,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: SizedBox(
                            height: 200,
                            child: DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  TabBar(
                                    tabs: const [
                                      Tab(text: 'Profile Pictures'),
                                      Tab(text: 'Video Posts'),
                                    ],
                                    labelColor: GlobalColors.primaryColor,
                                    unselectedLabelColor:
                                        GlobalColors.secondaryColor,
                                  ),
                                  SizedBox(
                                    height: 200,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: TabBarView(
                                        children: [
                                          // Pictures Tab
                                          GridView.builder(
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 4,
                                              mainAxisSpacing: 4,
                                            ),
                                            itemCount: targetProfile
                                                .profileImages!.length,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () => Routemaster.of(
                                                        context)
                                                    .push(
                                                        '/homepage/target-profile/image-viewer?url=${targetProfile.profileImages![index]['image_url']}&isMe=false&isProfilePic=false'),
                                                child: CachedNetworkImage(
                                                  imageUrl: targetProfile
                                                          .profileImages![index]
                                                      ['image_url'],
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                          ),
                                          // Videos Tab
                                          videoState.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: GlobalColors
                                                        .primaryColor,
                                                  ),
                                                )
                                              : videoState.data.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                        'No videos yet',
                                                        style: TextStyle(
                                                          color: GlobalColors
                                                              .secondaryColor,
                                                        ),
                                                      ),
                                                    )
                                                  : GridView.builder(
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 4,
                                                        mainAxisSpacing: 4,
                                                      ),
                                                      itemCount: videoState
                                                          .data.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Routemaster.of(
                                                                    context)
                                                                .push(
                                                                    '/homepage/target-profile/video-player?id=${Uri.encodeComponent(videoState.data[index]['id'].toString())}');
                                                          },
                                                          child: Container(
                                                            color: isLightTheme
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey[800],
                                                            height: 50,
                                                            width: 50,
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                    InkWell(
                      onTap: () {
                        if (expandedField == 'interest') {
                          setState(() {
                            expandedField = '';
                          });
                        } else {
                          setState(() {
                            expandedField = 'interest';
                          });
                        }
                      },
                      child: ListTile(
                        title: Text(
                          "${targetProfile.nickname}'s interests",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(targetProfile.lifesnapshots!
                            .map((snapshot) => snapshot['name'])
                            .join(", ")),
                        trailing: expandedField == 'interest'
                            ? const Icon(Icons.keyboard_arrow_down)
                            : const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    if (expandedField == 'interest')
                      Wrap(
                        children: targetProfile.lifesnapshots!
                            .map<Widget>((snapshot) {
                          return IntrinsicWidth(
                            child: Container(
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                  color: GlobalColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                              child: Text(
                                snapshot['name'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    InkWell(
                      onTap: () {
                        if (expandedField == 'target') {
                          setState(() {
                            expandedField = '';
                          });
                        } else {
                          setState(() {
                            expandedField = 'target';
                          });
                        }
                      },
                      child: ListTile(
                        title: Text(
                            "${targetProfile.nickname}'s interests in a person",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(targetProfile.targetLifesnapshots!
                            .map((snapshot) => snapshot['name'])
                            .join(", ")),
                        trailing: expandedField == 'target'
                            ? const Icon(Icons.keyboard_arrow_down)
                            : const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    if (expandedField == 'target')
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: targetProfile.targetLifesnapshots!
                            .map<Widget>((snapshot) {
                          return IntrinsicWidth(
                            child: Container(
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                  color: GlobalColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 5),
                              child: Text(
                                snapshot['name'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
