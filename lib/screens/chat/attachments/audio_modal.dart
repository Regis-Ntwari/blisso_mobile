import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioModal extends ConsumerStatefulWidget {
  final File audio;
  final String sender;
  final String receiver;
  const AudioModal(
      {super.key,
      required this.audio,
      required this.sender,
      required this.receiver});

  @override
  ConsumerState<AudioModal> createState() => _AudioModalState();
}

class _AudioModalState extends ConsumerState<AudioModal> {
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
    String extension = widget.audio.path.split('.').last;
    try {
      List<int> bytes = widget.audio.readAsBytesSync();
      String base64Bytes = base64Encode(bytes);
      ChatMessageModel messageModel = ChatMessageModel(
          messageId: generate12ByteHexFromTimestamp(DateTime.now()),
          contentFileType: 'audio/$extension',
          contentFile: base64Bytes,
          sender: widget.sender,
          receiver: widget.receiver,
          parentId: '000000000000000000000000',
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
        builder: (BuildContext context, BoxConstraints constraints) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              InkWell(
                onTap: () {},
                child: Container(
                  height: 100,
                  color: Colors.black,
                  child: const Align(
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.play_arrow, color: Colors.white, size: 30),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: captionController,
                        maxLines: 2,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: "Add a caption...",
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60)),
                              borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () => sendMessage(),
                        icon: const Icon(
                          Icons.send,
                          color: GlobalColors.primaryColor,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

void ShowAudioWithCaption(
    BuildContext context, File audio, String sender, String receiver) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return AudioModal(
        audio: audio,
        sender: sender,
        receiver: receiver,
      );
    },
  );
}
