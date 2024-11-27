import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostCardComponent extends StatelessWidget {
  final String photo;
  final String username;
  const PostCardComponent(
      {super.key, required this.photo, required this.username});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Card(
        elevation: 5,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(photo),
            ),
            title: Text(username),
            subtitle: const Text('Kigali, Rwanda'),
          ),
          CachedNetworkImage(
            imageUrl: photo,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height * 0.9,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                color: GlobalColors.primaryColor,
              ),
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              )),
        ]));
  }
}
