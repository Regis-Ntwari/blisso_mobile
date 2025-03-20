import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:blisso_mobile/screens/home/components/short_status_component.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';

class HomeComponent extends StatefulWidget {
  final List<dynamic>? profiles;
  final Function refetch;
  const HomeComponent(
      {super.key, required this.profiles, required this.refetch});

  @override
  State<HomeComponent> createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent> {
  final ScrollController _scrollController = ScrollController();

  Map<String, List<dynamic>> statuses = {
    'rex90danny@gmail.com': [
      {
        'url': 'https://images.unsplash.com/photo-1460472178825-e5240623afd5',
        'type': 'image',
        'profile': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2'
      },
      {
        'url': 'https://images.unsplash.com/photo-1583121274602-3e2820c69888',
        'type': 'image',
        'profile': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2'
      },
      {
        'url':
            'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b',
        'type': 'image',
        'profile': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2'
      },
    ],
    'schadrackniyibizi@gmail.com': [
      {
        'url': 'https://images.unsplash.com/photo-1583121274602-3e2820c69888',
        'type': 'image',
        'profile':
            'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b'
      },
      {
        'url':
            'https://plus.unsplash.com/premium_photo-1664297441375-d8c1928bf88f',
        'type': 'image',
        'profile':
            'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b'
      },
      {
        'url':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'type': 'video',
        'profile':
            'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b'
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return widget.profiles == null
        ? const LoadingScreen()
        : RefreshIndicator(
            backgroundColor: GlobalColors.primaryColor,
            color: GlobalColors.whiteColor,
            onRefresh: () => widget.refetch(),
            child: SizedBox(
              height: height,
              child: Column(
                children: [
                  ShortStatusComponent(statuses: statuses),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, index) => PostCardComponent(
                        profile: widget.profiles![index],
                      ),
                      itemCount: widget.profiles!.length,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
