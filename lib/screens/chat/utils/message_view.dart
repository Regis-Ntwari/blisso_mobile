import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blisso_mobile/components/view_picture_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class MessageView extends StatelessWidget {
  final dynamic message;
  const MessageView({super.key, required this.message});

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
                        print("Downloading file to: $savePath");
                        await Dio()
                            .download(message['content_file_url'], savePath);

                        // Check if the file exists
                        if (await File(savePath).exists()) {
                          print("File downloaded successfully at $savePath");

                          final result = await OpenFilex.open(savePath);

                          print(result.type);
                          print(result.message);
                        } else {
                          print("File not found at $savePath");
                        }
                      } catch (e) {
                        print("Error downloading file: $e");
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.file_copy), Text('document')],
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      Directory tempDir = await getTemporaryDirectory();
                      String tempFilePath =
                          '${tempDir.path}/${DateTime.now()}.${message['content_file_type'].toString().split('/')[1]}';
                      print(tempFilePath);
                      File tempFile = File(tempFilePath);
                      await tempFile
                          .writeAsBytes(base64Decode(message['content_file']));
                      await OpenFilex.open(tempFilePath);
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.file_copy), Text('document')],
                    ),
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
