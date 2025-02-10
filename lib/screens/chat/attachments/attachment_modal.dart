import 'dart:io';

import 'package:blisso_mobile/screens/chat/attachments/file_modal.dart';
import 'package:blisso_mobile/screens/chat/attachments/image_modal.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentModal extends StatefulWidget {
  final String sender;
  final String receiver;
  const AttachmentModal(
      {super.key, required this.sender, required this.receiver});

  @override
  State<AttachmentModal> createState() => _AttachmentModalState();
}

class _AttachmentModalState extends State<AttachmentModal> {
  File? pickedImage;
  File? takenPicture;

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
                              widget.sender, widget.receiver);
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
                          setState(() {
                            pickedImage = File(pickedFile.path);
                          });
                          showImageWithCaption(context, pickedImage!,
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
                                allowedExtensions: ['mp3', 'wav', 'mp4']);

                        if (result != null) {
                          File files = File(result.files.single.path!);
                          print(files.path);
                          PlatformFile file = result.files.first;

                          print(file.name);
                          print(file.bytes);
                          print(file.size);
                          print(file.extension);
                          print(file.path);
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
                              widget.sender, widget.receiver);
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
