import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blisso_mobile/screens/chat/attachments/audio_modal.dart';
import 'package:blisso_mobile/screens/chat/attachments/file_modal.dart';
import 'package:blisso_mobile/screens/chat/attachments/image_modal.dart';
import 'package:blisso_mobile/screens/chat/attachments/video_modal.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentModal extends ConsumerStatefulWidget {
  final String sender;
  final String receiver;
  const AttachmentModal(
      {super.key, required this.sender, required this.receiver});

  @override
  ConsumerState<AttachmentModal> createState() => _AttachmentModalState();
}

class _AttachmentModalState extends ConsumerState<AttachmentModal> {
  File? pickedImage;
  File? takenPicture;

  String generate12ByteHexFromTimestamp(DateTime dateTime) {
    int timestamp = dateTime.millisecondsSinceEpoch;

    String hexTimestamp = timestamp.toRadixString(16).padLeft(16, '0');

    final random = Random();
    String randomHex = List.generate(
        4, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

    return hexTimestamp + randomHex;
  }

  void sendMessage(File file) async {
    String extension = file.path.split('.').last;
    try {
      List<int> bytes = file.readAsBytesSync();
      String base64Bytes = base64Encode(bytes);
      ChatMessageModel messageModel = ChatMessageModel(
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          contentFileType: 'video/$extension',
          contentFile: base64Bytes,
          parentId: '000000000000000000000000',
          sender: widget.sender,
          receiver: widget.receiver,
          action: 'created',
          content: '',
          isFileIncluded: true,
          createdAt: DateTime.now().toUtc().toIso8601String());

      final messageRef = ref.read(webSocketNotifierProvider.notifier);

      messageRef.sendMessage(messageModel);

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            pickedImage = File(pickedFile.path);
                          });
                          showImageWithCaption(context, pickedImage!,
                              widget.sender, widget.receiver, null);
                        }
                      },
                      child: const CircleAvatar(
                        child: Icon(Icons.photo),
                      ),
                    ),
                    const Text('Photo')
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickVideo(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          // setState(() {
                          //   pickedImage = File(pickedFile.path);
                          // });
                          // showImageWithCaption(context, File(pickedFile.path),
                          //     widget.sender, widget.receiver);

                          //sendMessage(File(pickedFile.path));

                          ShowVideoWithCaption(context, File(pickedFile.path),
                              widget.sender, widget.receiver);
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: GlobalColors.secondaryColor,
                        child: const Icon(Icons.video_collection),
                      ),
                    ),
                    const Text('Video')
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                withData: true,
                                allowMultiple: false,
                                type: FileType.custom,
                                allowedExtensions: [
                              'mp3',
                              'wav',
                            ]);

                        if (result != null) {
                          PlatformFile file = result.files.first;

                          ShowAudioWithCaption(context, File(file.path!),
                              widget.sender, widget.receiver);
                        } else {
                          // User canceled the picker
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: const Icon(Icons.audio_file),
                      ),
                    ),
                    const Text('Audio')
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                withData: true,
                                allowMultiple: false,
                                allowedExtensions: [
                              'pdf',
                              'doc',
                              'docx',
                              'pptx',
                              'ppt',
                              'xlsx',
                              'xls',
                              'xml',
                            ]);

                        if (result != null) {
                          PlatformFile file = result.files.first;

                          showFileModal(
                              context, widget.sender, widget.receiver, file);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const CircleAvatar(
                        backgroundColor: GlobalColors.primaryColor,
                        child: Icon(Icons.file_copy),
                      ),
                    ),
                    const Text('Document')
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            takenPicture = File(pickedFile.path);
                          });
                          showImageWithCaption(context, takenPicture!,
                              widget.sender, widget.receiver, null);
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[700],
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                    const Text('Take Picture')
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

void showAttachmentOptions(
    BuildContext context, String sender, String receiver) {
  double width = MediaQuery.sizeOf(context).width;
  showModalBottomSheet(
    constraints: BoxConstraints(maxHeight: 200, maxWidth: width * 0.8),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return AttachmentModal(
        sender: sender,
        receiver: receiver,
      );
    },
  );
}
