import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class PostCardComponent extends StatefulWidget {
  final Map<String, dynamic> profile;
  const PostCardComponent({super.key, required this.profile});

  @override
  State<PostCardComponent> createState() => _PostCardComponentState();
}

class _PostCardComponentState extends State<PostCardComponent> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      child: Card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => Routemaster.of(context).push('/favorite-profile'),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.profile['profile_pic']),
            ),
            title: Text(widget.profile['nickname']),
            subtitle:
                Text('Location: ${widget.profile['distance_annot']} Away'),
            trailing: Icon(
              Icons.chat,
              color: GlobalColors.secondaryColor,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 2.8 / 4,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.profile['profile_images'][index]['image'],
                fit: BoxFit.contain,
                width: width,
                height: height,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: GlobalColors.primaryColor,
                  ),
                ),
              );
            },
            itemCount: widget.profile['profile_images'].length,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.profile['profile_images'].length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? GlobalColors.primaryColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
                textAlign: TextAlign.start,
                "${widget.profile['nickname']} is interested in ${widget.profile['target_lifesnapshots'].map((snapshot) => snapshot['name']).join(", ")}")),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
      ])),
    );
  }
}
