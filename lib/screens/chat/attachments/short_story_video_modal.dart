import 'dart:io';

import 'package:blisso_mobile/screens/utils/video_player.dart';
import 'package:blisso_mobile/services/stories/stories_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:routemaster/routemaster.dart';

class ShortStoryVideoModal extends ConsumerStatefulWidget {
  final File video;
  const ShortStoryVideoModal({
    super.key,
    required this.video,
  });

  @override
  ConsumerState<ShortStoryVideoModal> createState() =>
      _ShortStoryVideoModalState();
}

class _ShortStoryVideoModalState extends ConsumerState<ShortStoryVideoModal> {
  TextEditingController captionController = TextEditingController();

  void postShortVideoStory() async {
    Navigator.of(context).pop();
    try {
      Map<String, dynamic> videoStory = {
        'post_type': 'VIDEO',
        'caption': captionController.text,
        'post_file': widget.video
      };

      final shortStoryRef = ref.read(storiesServiceProviderImpl.notifier);

      await shortStoryRef.createStory(videoStory);
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
              VideoPlayer(videoFile: widget.video),
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
                        onPressed: () => postShortVideoStory(),
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

void showShortStoryVideoWithCaption(
  BuildContext context,
  File video,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return ShortStoryVideoModal(
        video: video,
      );
    },
  );
}
