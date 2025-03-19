import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewPictureStatusComponent extends StatelessWidget {
  final dynamic image;
  const ViewPictureStatusComponent({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRect(
            child: SizedBox(
                width: double.infinity,
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                      color: GlobalColors.primaryColor,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

void showPictureStatusDialog(
    {required BuildContext context, required dynamic image}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return ViewPictureStatusComponent(
            image: image,
          );
        },
      );
    },
  );
}
