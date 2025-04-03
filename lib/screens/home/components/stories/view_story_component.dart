import 'dart:convert';

import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';

class ViewStoryComponent extends StatefulWidget {
  const ViewStoryComponent({super.key});

  @override
  State<ViewStoryComponent> createState() => _ViewStoryPageState();
}

class _ViewStoryPageState extends State<ViewStoryComponent> {
  int currentIndex = 0;
  VideoPlayerController? _videoController;
  List<Map<String, dynamic>> stories = [];
  bool _isDataLoaded = false;
  String nickname = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNickname();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadData();
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  void _loadData() {
    final queryParams = Routemaster.of(context).currentRoute.queryParameters;
    String? encodedData = queryParams['data'];

    if (encodedData != null) {
      setState(() {
        stories = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
      });
      _loadStory();
    }
  }

  void _loadStory() {
    if (stories[currentIndex]['post_type'] == 'VIDEO') {
      _videoController = VideoPlayerController.networkUrl(
          Uri.parse(stories[currentIndex]['post_file_url']))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  Future<void> getNickname() async {
    String? nick = await SharedPreferencesService.getPreference('nickname');

    if (nick != null) {
      nickname = nick;
    }
  }

  void _nextStory() {
    if (currentIndex < stories.length - 1) {
      setState(() {
        currentIndex++;
        _videoController?.dispose();
        _loadStory();
      });
    } else {
      Navigator.pop(context); // Close story view when finished
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _videoController?.dispose();
        _loadStory();
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isDataLoaded
          ? const CircularProgressIndicator(
              color: GlobalColors.primaryColor,
            )
          : GestureDetector(
              onTapUp: (details) {
                if (details.globalPosition.dx <
                    MediaQuery.of(context).size.width / 2) {
                  _previousStory();
                } else {
                  _nextStory();
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: stories[currentIndex]['post_type'] == 'IMAGE'
                        ? CachedNetworkImage(
                            imageUrl: stories[currentIndex]['post_file_url'],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: GlobalColors.primaryColor,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                          )
                        : _videoController != null &&
                                _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: GlobalColors.primaryColor,
                              )),
                  ),
                  Positioned(
                    top: 50,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                      bottom: 130,
                      left: 10,
                      child: Text(
                        stories[currentIndex]['nickname'] == nickname
                            ? 'My Story'
                            : stories[currentIndex]['nickname'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                  Positioned(
                      bottom: 110,
                      left: 10,
                      child: stories[currentIndex]['caption'] != null
                          ? Text(
                              stories[currentIndex]['caption'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          : const SizedBox.shrink()),
                  Positioned(
                      bottom: 50,
                      left: 5,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite)),
                          IconButton(
                              onPressed: () {}, icon: const Icon(Icons.reply)),
                          IconButton(
                              onPressed: () {}, icon: const Icon(Icons.share))
                        ],
                      )),
                  Positioned(
                    top: 40,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: List.generate(stories.length, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: index <= currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
