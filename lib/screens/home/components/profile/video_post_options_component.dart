import 'dart:io';

import 'package:blisso_mobile/screens/chat/attachments/short_story_image_modal.dart';
import 'package:blisso_mobile/screens/chat/attachments/short_story_video_modal.dart';
import 'package:blisso_mobile/services/stories/delete_video_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class VideoPostOptionsComponent extends ConsumerStatefulWidget {
  final int id;
  const VideoPostOptionsComponent({super.key, required this.id});

  @override
  ConsumerState<VideoPostOptionsComponent> createState() =>
      _ChooseStoryComponentState();
}

class _ChooseStoryComponentState
    extends ConsumerState<VideoPostOptionsComponent> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    await ref
                        .read(deleteVideoPostProviderImpl.notifier)
                        .deleteVideoPost(widget.id);
                    Navigator.of(context).pop();
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.delete),
                      ),
                      Text('Delete Video Post')
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

void showVideoPostOptions(BuildContext context, int id) {
  showModalBottomSheet(
    constraints: const BoxConstraints(maxHeight: 200),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return VideoPostOptionsComponent(id: id);
    },
  );
}
