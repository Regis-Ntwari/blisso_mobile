import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blisso_mobile/components/view_picture_component.dart';
import 'package:blisso_mobile/screens/utils/video_player.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class MessageView extends StatelessWidget {
  final dynamic message;
  const MessageView({super.key, required this.message});

  Future<String?> generateThumbnailFile(Uint8List bytes) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String videoPath = '${tempDir.path}/temp_video.mp4';
      File videoFile = File(videoPath);
      await videoFile.writeAsBytes(bytes);

      // Step 2: Generate a thumbnail
      XFile? thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200, // Set thumbnail size
        quality: 75,
      );

      return thumbPath.path;
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }

  Future<String?> generateThumbnailNetwork(String url) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight:
            100, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 75,
      );

      return thumbnail.path;
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return message['content_file_type'].toString().startsWith('image/')
        ? message['content_file_url'].toString().startsWith('https:')
            ? Wrap(
                children: [
                  InkWell(
                    onTap: () => showPictureDialog(
                        context: context,
                        image: {'image_uri': message['content_file_url']},
                        isEdit: false,
                        chosenPicture: null,
                        updatePicture: () {},
                        savePicture: () {}),
                    child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              color: GlobalColors.primaryColor,
                            ),
                        imageUrl: message['content_file_url']),
                  ),
                  Text(message['content'])
                ],
              )
            : Wrap(
                children: [
                  InkWell(
                    child: Image.memory(Uint8List.fromList(
                        base64Decode(message['content_file']))),
                  ),
                  Text(message['content'])
                ],
              )
        : message['content_file_type'].toString().startsWith('file/')
            ? message['content_file_url'].toString().startsWith('https')
                ? InkWell(
                    onTap: () async {
                      var tempDir = await getTemporaryDirectory();

                      // Extract file name from URL
                      String fileName =
                          message['content_file_url'].split('/').last;

                      // Define save path
                      String savePath = "${tempDir.path}/$fileName";

                      // Download file
                      try {
                        debugPrint("Downloading file to: $savePath");
                        await Dio()
                            .download(message['content_file_url'], savePath);

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
                          children: [Icon(Icons.file_copy), Text('document')],
                        ),
                        Text(message['content'])
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      Directory tempDir = await getTemporaryDirectory();
                      String tempFilePath =
                          '${tempDir.path}/${DateTime.now()}.${message['content_file_type'].toString().split('/')[1]}';
                      File tempFile = File(tempFilePath);
                      await tempFile
                          .writeAsBytes(base64Decode(message['content_file']));
                      await OpenFilex.open(tempFilePath);
                    },
                    child: Column(
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.file_copy), Text('document')],
                        ),
                        message['content'] == ''
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Text(message['content']),
                              )
                      ],
                    ),
                  )
            : message['content_file_type'].toString().startsWith('video/')
                ? VideoPlayer(
                    message: message,
                  )
                : Text(
                    message['content']!,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  );
  }
}
