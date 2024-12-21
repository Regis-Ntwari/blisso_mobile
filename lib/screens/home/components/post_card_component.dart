import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class PostCardComponent extends ConsumerStatefulWidget {
  final Map<String, dynamic> profile;
  const PostCardComponent({super.key, required this.profile});

  @override
  ConsumerState<PostCardComponent> createState() => _PostCardComponentState();
}

class _PostCardComponentState extends ConsumerState<PostCardComponent> {
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
    final targetProfile = ref.read(targetProfileProvider.notifier);
    return SizedBox(
      child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: () {
                targetProfile.updateTargetProfile(
                    TargetProfileModel.fromMap(widget.profile));
                Routemaster.of(context).push('/target-profile');
              },
              child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        widget.profile['profile_picture_uri']),
                  ),
                  contentPadding: const EdgeInsets.only(left: 5),
                  horizontalTitleGap: 10,
                  title: Row(
                    children: [
                      Text(widget.profile['nickname']),
                      Text(' - ${widget.profile['age']} years old')
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.location_on),
                      Text('${widget.profile['distance_annot']}'),
                    ],
                  )),
            ),
            SizedBox(
              height: height * 0.55,
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
                    imageUrl: widget.profile['profile_images'][index]
                        ['image_uri'],
                    fit: BoxFit.contain,
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
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 100,
                      child: ButtonComponent(
                          text: 'Message',
                          backgroundColor: GlobalColors.primaryColor,
                          foregroundColor: GlobalColors.whiteColor,
                          buttonHeight: 40,
                          buttonWidth: 100,
                          onTap: () {}),
                    )
                  ],
                )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    textAlign: TextAlign.start,
                    "${widget.profile['nickname']} is interested in ${widget.profile['target_lifesnapshots'].map((snapshot) => snapshot['name']).join(", ")}")),
          ])),
    );
  }
}
