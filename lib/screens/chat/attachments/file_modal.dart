import 'dart:convert';
import 'dart:math';

import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileModal extends ConsumerStatefulWidget {
  final BuildContext context;
  final String sender;
  final String receiver;
  final PlatformFile file;
  const FileModal(
      {super.key,
      required this.sender,
      required this.receiver,
      required this.file,
      required this.context});

  @override
  ConsumerState<FileModal> createState() => _FileModalState();
}

class _FileModalState extends ConsumerState<FileModal> {
  TextEditingController captionController = TextEditingController();

  String generate12ByteHexFromTimestamp(DateTime dateTime) {
    int timestamp = dateTime.millisecondsSinceEpoch;

    String hexTimestamp = timestamp.toRadixString(16).padLeft(16, '0');

    final random = Random();
    String randomHex = List.generate(
        4, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

    return hexTimestamp + randomHex;
  }

  void sendMessage() async {
    String extension = widget.file.extension!;

    try {
      List<int> bytes = widget.file.bytes!;
      String base64Bytes = base64Encode(bytes);
      ChatMessageModel messageModel = ChatMessageModel(
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          contentFileType: 'file/$extension',
          contentFile: base64Bytes,
          sender: widget.sender,
          receiver: widget.receiver,
          action: 'created',
          content: captionController.text,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.file.name),
                TextField(
                  controller: captionController,
                  maxLines: 2,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Add a caption...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                ButtonComponent(
                    text: 'Send Document',
                    backgroundColor: GlobalColors.primaryColor,
                    foregroundColor: GlobalColors.lightBackgroundColor,
                    onTap: () {
                      sendMessage();
                      //Navigator.of(widget.context).pop();
                    })
              ],
            ),
          ),
        );
      },
    );
  }
}

void showFileModal(
    BuildContext ctx, String sender, String receiver, PlatformFile file) {
  showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FileModal(
          sender: sender,
          receiver: receiver,
          file: file,
          context: ctx,
        );
      });
}
