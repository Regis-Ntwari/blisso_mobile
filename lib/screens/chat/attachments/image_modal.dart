import 'dart:io';

import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class ImageModal extends StatefulWidget {
  const ImageModal({super.key});

  @override
  State<ImageModal> createState() => _ImageModalState();
}

class _ImageModalState extends State<ImageModal> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

void showImageWithCaption(BuildContext context, File image) {
  TextEditingController captionController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Flexible(
                    child: Image.file(
                      image,
                      width: double.infinity,
                      fit: BoxFit.contain,
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
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
    },
  );
}
