import 'dart:io';

import 'package:flutter/material.dart';

class VideoModal extends StatefulWidget {
  final String sender;
  final String receiver;
  final File video;
  const VideoModal(
      {super.key,
      required this.sender,
      required this.receiver,
      required this.video});

  @override
  State<VideoModal> createState() => _VideoModalState();
}

class _VideoModalState extends State<VideoModal> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

void ShowVideoWithCaption(
    BuildContext context, File video, String sender, String receiver) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return VideoModal(
        video: video,
        sender: sender,
        receiver: receiver,
      );
    },
  );
}
