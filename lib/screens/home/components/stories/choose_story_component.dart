import 'dart:io';

import 'package:blisso_mobile/screens/chat/attachments/short_story_image_modal.dart';
import 'package:blisso_mobile/screens/chat/attachments/video_modal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChooseStoryComponent extends StatefulWidget {
  const ChooseStoryComponent({super.key});

  @override
  State<ChooseStoryComponent> createState() => _ChooseStoryComponentState();
}

class _ChooseStoryComponentState extends State<ChooseStoryComponent> {
  File? pickedImage;
  File? pickedVideo;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Choose File',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      showShortStoryImageWithCaption(context, pickedImage!);
                    }
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.image),
                      ),
                      Text('Pictures')
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickVideo(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      setState(() {
                        pickedVideo = File(pickedFile.path);
                      });
                      ShowVideoWithCaption(context, pickedVideo!, '', '');
                    }
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.yellow,
                          child: Icon(Icons.video_camera_front)),
                      Text('Videos')
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

void showChooseStoryOptions(BuildContext context) {
  showModalBottomSheet(
    constraints: const BoxConstraints(maxHeight: 200),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return const ChooseStoryComponent();
    },
  );
}
