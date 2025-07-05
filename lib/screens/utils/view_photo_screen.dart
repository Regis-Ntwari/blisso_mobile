import 'dart:convert';
import 'dart:typed_data';

import 'package:blisso_mobile/utils/byte_image_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewPhotoScreen extends ConsumerWidget {
  final String imageURL;
  bool isBytes;
  ViewPhotoScreen({super.key, required this.imageURL, this.isBytes = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    if(isBytes) {

    }
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
        child: isBytes
            ? Image.memory(Uint8List.fromList(base64Decode(ref.read(byteImageProviderImpl))))
            : CachedNetworkImage(
                imageUrl: imageURL,
                errorWidget: (context, url, error) => Icon(
                  Icons.no_photography,
                  color: isLightTheme ? Colors.black : Colors.white,
                ),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: GlobalColors.primaryColor,
                  ),
                ),
              ),
      ),
    ));
  }
}
