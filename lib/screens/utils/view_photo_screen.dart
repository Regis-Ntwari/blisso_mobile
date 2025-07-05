import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewPhotoScreen extends StatelessWidget {
  final String imageURL;
  const ViewPhotoScreen({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
        child: Scaffold(
          backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        title: const Text('Image'),

        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: isLightTheme ? Colors.black : Colors.white,
            )),
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageURL,
          errorWidget: (context, url, error) => Icon(
            Icons.no_photography,
            color: isLightTheme ? Colors.black : Colors.white,
          ),
          placeholder: (context, url) => const CircularProgressIndicator(
            color: GlobalColors.primaryColor,
          ),
        ),
      ),
    ));
  }
}
