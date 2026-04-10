import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blisso_mobile/screens/utils/audio_player.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/byte_image_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:routemaster/routemaster.dart';

class MessageView extends ConsumerStatefulWidget {
  final dynamic message;
  final Function scrollToParent;
  final String username;
  const MessageView(
      {super.key,
      required this.message,
      required this.scrollToParent,
      required this.username});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  String? username;

  bool isLoading = false;
  Future<void> getMyUsername() async {
    await SharedPreferencesService.getPreference('username').then((use) {
      if (mounted) {
        setState(() {
          username = use;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (username == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getMyUsername();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: GlobalColors.primaryColor,
            ),
          )
        : widget.message['content_file_type'].toString().startsWith('image/')
            ? widget.message['content_file_url'].toString().startsWith('https:')
                ? Wrap(
                    children: [
                      widget.message['parent_id'] != '000000000000000000000000'
                          ? InkWell(
                              onTap: null,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                color: isLightTheme
                                    ? username == widget.message['sender']
                                        ? GlobalColors.myLightReplyMessageColor
                                        : Colors.grey[200]
                                    : username == widget.message['sender']
                                        ? GlobalColors.myDarkReplyMessageColor
                                        : Colors.grey[700],
                                child: Text(widget.message['parent_content']),
                              ),
                            )
                          : const SizedBox.shrink(),
                      InkWell(
                        onTap: () async{
                          String username = await SharedPreferencesService.getPreference('username');
                          String chatUser =
                              username == widget.message['sender']
                                  ? widget.message['receiver']
                                  : widget.message['sender'];
                          Routemaster.of(context)
                              .push('/homepage/chat-detail/$chatUser/image-viewer?url=${widget.message['content_file_url']}&isMe=false&isProfilePic=false');
                        },
                        child: SizedBox(
                          height: 400,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: GlobalColors.primaryColor,
                                    ),
                                  ),
                              imageUrl: widget.message['content_file_url']),
                        ),
                      ),
                      Text(widget.message['content'])
                    ],
                  )
                : Wrap(
                  direction: Axis.vertical,
                    children: [
                      widget.message['parent_id'] != '000000000000000000000000'
                          ? InkWell(
                              onTap: null,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                color: isLightTheme
                                    ? username == widget.message['sender']
                                        ? GlobalColors.myLightReplyMessageColor
                                        : Colors.grey[400]
                                    : username == widget.message['sender']
                                        ? GlobalColors.myDarkReplyMessageColor
                                        : Colors.grey[700],
                                child: Text(widget.message['parent_content']),
                              ),
                            )
                          : const SizedBox.shrink(),
                      InkWell(
                        onTap: () async{
                          String username = await SharedPreferencesService.getPreference('username');
                          String chatUser =
                              username == widget.message['sender']
                                  ? widget.message['receiver']
                                  : widget.message['sender'];

                          ref.read(byteImageProviderImpl.notifier).updateState(widget.message['content_file']);
                          Routemaster.of(context)
                              .push('/homepage/chat-detail/$chatUser/image-viewer?url=hellothere&isProfilePic=false&isMe=false&bytes=true');
                          
                        },
                        child: SizedBox(
                          height: 400,
                          child: Image.memory(Uint8List.fromList(
                              base64Decode(widget.message['content_file']))),
                        ),
                      ),
                      Text(widget.message['content'])
                    ],
                  )
            : widget.message['content_file_type'].toString().startsWith('file/')
                ? widget.message['content_file_url']
                        .toString()
                        .startsWith('https')
                    ? Wrap(
                        children: [
                          widget.message['parent_id'] !=
                                  '000000000000000000000000'
                              ? InkWell(
                                  onTap: null,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    color: isLightTheme
                                        ? username == widget.message['sender']
                                            ? GlobalColors
                                                .myLightReplyMessageColor
                                            : Colors.grey[400]
                                        : username == widget.message['sender']
                                            ? GlobalColors
                                                .myDarkReplyMessageColor
                                            : Colors.grey[700],
                                    child:
                                        Text(widget.message['parent_content']),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          InkWell(
                            onTap: () async {
                              var tempDir = await getTemporaryDirectory();

                              // Extract file name from URL
                              String fileName = widget
                                  .message['content_file_url']
                                  .split('/')
                                  .last;

                              // Define save path
                              String savePath = "${tempDir.path}/$fileName";

                              // Download file
                              try {
                                debugPrint("Downloading file to: $savePath");
                                await Dio().download(
                                    widget.message['content_file_url'],
                                    savePath);

                                // Check if the file exists
                                if (await File(savePath).exists()) {
                                  debugPrint(
                                      "File downloaded successfully at $savePath");

                                  final result = await OpenFilex.open(savePath);

                                  debugPrint(result.type.toString());
                                  debugPrint(result.message);
                                } else {
                                  debugPrint("File not found at $savePath");
                                }
                              } catch (e) {
                                debugPrint("Error downloading file: $e");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isLightTheme
                                    ? Colors.grey[100]
                                    : Colors.grey[850],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLightTheme
                                      ? Colors.grey[300]!
                                      : Colors.grey[700]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: GlobalColors.primaryColor
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: GlobalColors.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.message['content_file_url']
                                                  .toString()
                                                  .split('/')
                                                  .last
                                                  .split('?')
                                                  .first,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isLightTheme
                                                ? Colors.black87
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.message['content_file_type']
                                              .toString()
                                              .split('/')
                                              .last
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isLightTheme
                                                ? Colors.grey[600]
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.download_rounded,
                                    color: GlobalColors.primaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.message['content'] != null &&
                              widget.message['content'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(widget.message['content']),
                            ),
                        ],
                      )
                    : Wrap(
                        children: [
                          widget.message['parent_id'] !=
                                  '000000000000000000000000'
                              ? InkWell(
                                  onTap: null,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    color: isLightTheme
                                        ? username == widget.message['sender']
                                            ? GlobalColors
                                                .myLightReplyMessageColor
                                            : Colors.grey[400]
                                        : username == widget.message['sender']
                                            ? GlobalColors
                                                .myDarkReplyMessageColor
                                            : Colors.grey[700],
                                    child:
                                        Text(widget.message['parent_content']),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          InkWell(
                            onTap: () async {
                              Directory tempDir = await getTemporaryDirectory();
                              String tempFilePath =
                                  '${tempDir.path}/${DateTime.now()}.${widget.message['content_file_type'].toString().split('/')[1]}';
                              File tempFile = File(tempFilePath);
                              await tempFile.writeAsBytes(
                                  base64Decode(widget.message['content_file']));
                              await OpenFilex.open(tempFilePath);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isLightTheme
                                    ? Colors.grey[100]
                                    : Colors.grey[850],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLightTheme
                                      ? Colors.grey[300]!
                                      : Colors.grey[700]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: GlobalColors.primaryColor
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: GlobalColors.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Document',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isLightTheme
                                                ? Colors.black87
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget
                                              .message['content_file_type']
                                              .toString()
                                              .split('/')
                                              .last
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isLightTheme
                                                ? Colors.grey[600]
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    color: GlobalColors.primaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.message['content'] != null &&
                              widget.message['content'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(widget.message['content']),
                            ),
                        ],
                      )
                : widget.message['content_file_type']
                        .toString()
                        .startsWith('video/')
                    ? widget.message['content_file_url']
                            .toString()
                            .startsWith('https')
                        ? Wrap(
                            children: [
                              widget.message['parent_id'] !=
                                      '000000000000000000000000'
                                  ? InkWell(
                                      onTap: null,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        color: isLightTheme
                                            ? username ==
                                                    widget.message['sender']
                                                ? GlobalColors
                                                    .myLightReplyMessageColor
                                                : Colors.grey[400]
                                            : username ==
                                                    widget.message['sender']
                                                ? GlobalColors
                                                    .myDarkReplyMessageColor
                                                : Colors.grey[700],
                                        child: Text(
                                            widget.message['parent_content']),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              InkWell(
                                onTap: () {
                                  String chatUser =
                                      username == widget.message['sender']
                                          ? widget.message['receiver']
                                          : widget.message['sender'];
                                  Routemaster.of(context).push(
                                      '/homepage/chat-detail/$chatUser/video-player?videoUrl=${Uri.encodeComponent(widget.message['content_file_url'])}&bytes=${Uri.encodeComponent(widget.message['content_file'] ?? '')}');
                                },
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.videocam_rounded,
                                                  color: Colors.white,
                                                  size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                'Video',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.message['content'] != null &&
                                  widget.message['content']
                                      .toString()
                                      .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    widget.message['content'],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                            ],
                          )
                        : Wrap(
                            children: [
                              widget.message['parent_id'] !=
                                      '000000000000000000000000'
                                  ? InkWell(
                                      onTap: null,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        color: isLightTheme
                                            ? username ==
                                                    widget.message['sender']
                                                ? GlobalColors
                                                    .myLightReplyMessageColor
                                                : Colors.grey[400]
                                            : username ==
                                                    widget.message['sender']
                                                ? GlobalColors
                                                    .myDarkReplyMessageColor
                                                : Colors.grey[700],
                                        child: Text(
                                            widget.message['parent_content']),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              InkWell(
                                onTap: () {
                                  String chatUser =
                                      username == widget.message['sender']
                                          ? widget.message['receiver']
                                          : widget.message['sender'];
                                  Routemaster.of(context).push(
                                      '/homepage/chat-detail/$chatUser/video-player?videoUrl=${Uri.encodeComponent(widget.message['content_file_url'] ?? '')}&bytes=${Uri.encodeComponent(widget.message['content_file'])}');
                                },
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.videocam_rounded,
                                                  color: Colors.white,
                                                  size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                'Video',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.message['content'] != null &&
                                  widget.message['content']
                                      .toString()
                                      .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    widget.message['content'],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                            ],
                          )
                    : widget.message['content_file_type']
                            .toString()
                            .startsWith('audio/')
                        ? Wrap(
                            children: [
                              widget.message['parent_id'] !=
                                      '000000000000000000000000'
                                  ? InkWell(
                                      onTap: null,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        color: isLightTheme
                                            ? username ==
                                                    widget.message['sender']
                                                ? GlobalColors
                                                    .myLightReplyMessageColor
                                                : Colors.grey[400]
                                            : username ==
                                                    widget.message['sender']
                                                ? GlobalColors
                                                    .myDarkReplyMessageColor
                                                : Colors.grey[700],
                                        child: Text(
                                            widget.message['parent_content']),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              AudioPlayer(message: widget.message),
                            ],
                          )
                        : widget.message['parent_content']
                                .toString()
                                .startsWith('Story')
                            ? Wrap(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      String chatUser =
                                          username == widget.message['sender']
                                              ? widget.message['receiver']
                                              : widget.message['sender'];
                                      Routemaster.of(context).push(
                                          '/homepage/chat-detail/$chatUser/story-player?id=${widget.message['content_file_type']}');
                                      // final shortStoryRef = ref.read(
                                      //     getOneStoryProviderImpl.notifier);

                                      // dynamic status =
                                      //     shortStoryRef.getOneStory(
                                      //         widget.message['parent_id']);
                                      // String encodedData = jsonEncode([status]);
                                      // Routemaster.of(context).push(
                                      //     '/homepage/view-story?data=$encodedData');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      color: isLightTheme
                                          ? username == widget.message['sender']
                                              ? GlobalColors
                                                  .myLightReplyMessageColor
                                              : Colors.grey[400]
                                          : username == widget.message['sender']
                                              ? GlobalColors
                                                  .myDarkReplyMessageColor
                                              : Colors.grey[700],
                                      child: Text(
                                          'Click to View ${widget.message['parent_content']}'),
                                    ),
                                  ),
                                  Text(
                                    '${widget.message['content'] ?? ''}',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : widget.message['content_file_type'] == 'Profile'
                                ? ListTile(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      final profileRef = ref.read(
                                          anyProfileServiceProviderImpl
                                              .notifier);
                                      await profileRef.getAnyProfile(
                                          widget.message['parent_content']);

                                      final profile = ref
                                          .read(anyProfileServiceProviderImpl);

                                      final targetProfile = ref
                                          .read(targetProfileProvider.notifier);
                                      targetProfile.updateTargetProfile(
                                          TargetProfileModel.fromMap(
                                              profile.data));
                                      String chatUser =
                                          username == widget.message['sender']
                                              ? widget.message['receiver']
                                              : widget.message['sender'];
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Routemaster.of(context).push(
                                          '/homepage/chat-detail/$chatUser/profile');
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        widget.message['content_file_url'],
                                      ),
                                    ),
                                    title: Text(widget.message['content']),
                                  )
                                : widget.message['content_file_type'] ==
                                        'Video_post'
                                    ? ListTile(
                                        onTap: () {
                                          String chatUser = username ==
                                                  widget.message['sender']
                                              ? widget.message['receiver']
                                              : widget.message['sender'];
                                          Routemaster.of(context).push(
                                              '/homepage/chat-detail/$chatUser/${widget.message['parent_content']}');
                                        },
                                        leading: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        title: Text(
                                            'View ${widget.message['content'] ?? ''}'),
                                      )
                                    : Wrap(
                                        children: [
                                          widget.message['parent_id'] !=
                                                  '000000000000000000000000'
                                              ? Wrap(
                                                  children: [
                                                    InkWell(
                                                      onTap: null,
                                                      child: Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 10),
                                                        color: isLightTheme
                                                            ? username ==
                                                                    widget.message[
                                                                        'sender']
                                                                ? GlobalColors
                                                                    .myLightReplyMessageColor
                                                                : Colors
                                                                    .grey[400]
                                                            : username ==
                                                                    widget.message[
                                                                        'sender']
                                                                ? GlobalColors
                                                                    .myDarkReplyMessageColor
                                                                : Colors
                                                                    .grey[700],
                                                        child: Text(widget
                                                                .message[
                                                            'parent_content']),
                                                      ),
                                                    ),
                                                    Text(
                                                      widget
                                                          .message['content'] ?? '',
                                                      textAlign:
                                                          TextAlign.left,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  widget.message['content'] ?? '',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                        ],
                                      );
  }
}
