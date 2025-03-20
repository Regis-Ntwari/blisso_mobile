import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blisso_mobile/components/view_picture_bytes_component.dart';
import 'package:blisso_mobile/components/view_picture_component.dart';
import 'package:blisso_mobile/screens/utils/audio_player.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:routemaster/routemaster.dart';

class MessageView extends StatefulWidget {
  final dynamic message;
  final Function scrollToParent;
  final String username;
  const MessageView(
      {super.key,
      required this.message,
      required this.scrollToParent,
      required this.username});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  String? username;
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
    return widget.message['content_file_type'].toString().startsWith('image/')
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
                    onTap: () => showPictureDialog(
                        context: context,
                        image: {
                          'image_uri': widget.message['content_file_url']
                        },
                        isEdit: false,
                        chosenPicture: null,
                        updatePicture: () {},
                        savePicture: () {}),
                    child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              color: GlobalColors.primaryColor,
                            ),
                        imageUrl: widget.message['content_file_url']),
                  ),
                  Text(widget.message['content'])
                ],
              )
            : Wrap(
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
                    onTap: () {
                      showPictureBytesDialog(
                          context: context,
                          image: widget.message['content_file']);
                    },
                    child: Image.memory(Uint8List.fromList(
                        base64Decode(widget.message['content_file']))),
                  ),
                  Text(widget.message['content'])
                ],
              )
        : widget.message['content_file_type'].toString().startsWith('file/')
            ? widget.message['content_file_url'].toString().startsWith('https')
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
                                        : Colors.grey[400]
                                    : username == widget.message['sender']
                                        ? GlobalColors.myDarkReplyMessageColor
                                        : Colors.grey[700],
                                child: Text(widget.message['parent_content']),
                              ),
                            )
                          : const SizedBox.shrink(),
                      InkWell(
                        onTap: () async {
                          var tempDir = await getTemporaryDirectory();

                          // Extract file name from URL
                          String fileName = widget.message['content_file_url']
                              .split('/')
                              .last;

                          // Define save path
                          String savePath = "${tempDir.path}/$fileName";

                          // Download file
                          try {
                            debugPrint("Downloading file to: $savePath");
                            await Dio().download(
                                widget.message['content_file_url'], savePath);

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
                        child: Column(
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.file_open,
                                  size: 30,
                                ),
                                Text('document')
                              ],
                            ),
                            Text(widget.message['content'])
                          ],
                        ),
                      ),
                    ],
                  )
                : Wrap(
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
                        onTap: () async {
                          Directory tempDir = await getTemporaryDirectory();
                          String tempFilePath =
                              '${tempDir.path}/${DateTime.now()}.${widget.message['content_file_type'].toString().split('/')[1]}';
                          File tempFile = File(tempFilePath);
                          await tempFile.writeAsBytes(
                              base64Decode(widget.message['content_file']));
                          await OpenFilex.open(tempFilePath);
                        },
                        child: Column(
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.file_open,
                                  size: 30,
                                ),
                                Text('document')
                              ],
                            ),
                            widget.message['content'] == ''
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 1.0),
                                    child: Text(widget.message['content']),
                                  )
                          ],
                        ),
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
                            onTap: () {
                              Routemaster.of(context).push(
                                  '/chat-detail/$username/video-player?videoUrl=${Uri.encodeComponent(widget.message['content_file_url'])}&bytes=${Uri.encodeComponent(widget.message['content_file'] ?? '')}');
                            },
                            child: Container(
                              height: 300,
                              color: Colors.black,
                              child: const Align(
                                alignment: Alignment.center,
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white, size: 30),
                              ),
                            ),
                          ),
                          Text(
                            widget.message['content']!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
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
                            onTap: () {
                              Routemaster.of(context).push(
                                  '/chat-detail/$username/video-player?videoUrl=${Uri.encodeComponent(widget.message['content_file_url'] ?? '')}&bytes=${Uri.encodeComponent(widget.message['content_file'])}');
                            },
                            child: Container(
                              height: 300,
                              color: Colors.black,
                              child: const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            widget.message['content']!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
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
                          AudioPlayer(message: widget.message),
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
                          Text(
                            widget.message['content']!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
  }
}
