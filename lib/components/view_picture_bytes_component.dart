import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ViewPictureBytesComponent extends StatelessWidget {
  final dynamic image;
  const ViewPictureBytesComponent({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRect(
            child: SizedBox(
              width: double.infinity,
              child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: Image.memory(Uint8List.fromList(base64Decode(image)))),
            ),
          ),
        ],
      ),
    );
  }
}

void showPictureBytesDialog(
    {required BuildContext context, required dynamic image}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return ViewPictureBytesComponent(
            image: image,
          );
        },
      );
    },
  );
}
