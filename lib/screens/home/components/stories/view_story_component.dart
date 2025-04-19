import 'dart:convert';
import 'dart:math';

import 'package:blisso_mobile/services/models/chat_message_model.dart';
import 'package:blisso_mobile/services/shared_preferences_service.dart';
import 'package:blisso_mobile/services/websocket/websocket_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';

class ViewStoryComponent extends ConsumerStatefulWidget {
  const ViewStoryComponent({super.key});

  @override
  ConsumerState<ViewStoryComponent> createState() => _ViewStoryPageState();
}

class _ViewStoryPageState extends ConsumerState<ViewStoryComponent> {
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
      getMyUsername();
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
    await SharedPreferencesService.getPreference('nickname').then((nick) {
      setState(() {
        nickname = nick;
      });
    });
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

  String generate12ByteHexFromTimestamp(DateTime dateTime) {
    // Convert DateTime to Unix timestamp in milliseconds
    int timestamp = dateTime.millisecondsSinceEpoch;

    // Convert timestamp (8 bytes) to hex
    String hexTimestamp = timestamp.toRadixString(16).padLeft(16, '0');

    // Generate 4 random bytes (8 hex characters)
    final random = Random();
    String randomHex = List.generate(
        4, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

    // Combine timestamp + random bytes (12 bytes = 24 hex characters)
    return hexTimestamp + randomHex;
  }

  String? username;
  Future<void> getMyUsername() async {
    await SharedPreferencesService.getPreference('username').then((use) {
      setState(() {
        username = use;
      });
    });
  }

  void sendReply(String toUsername) {
    ChatMessageModel messageModel = ChatMessageModel(
        messageId: generate12ByteHexFromTimestamp(DateTime.now()),
        parentId: '000000000000000000000000',
        parentContent: 'Story',
        sender: username!,
        receiver: toUsername,
        action: 'created',
        content: replyController.text,
        isFileIncluded: false,
        createdAt: DateTime.now().toUtc().toIso8601String());

    final messageRef = ref.read(webSocketNotifierProvider.notifier);

    messageRef.sendMessage(messageModel);
  }

  TextEditingController replyController = TextEditingController();

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightTheme ? Colors.white : Colors.black,
      body: !_isDataLoaded
          ? const Center(
              child: CircularProgressIndicator(
                color: GlobalColors.primaryColor,
              ),
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
                                ),
                              ),
                  ),
                  Positioned(
                    top: 50,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          color: isLightTheme ? Colors.black : Colors.white),
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
                    ),
                  ),
                  Positioned(
                    bottom: 110,
                    left: 10,
                    child: stories[currentIndex]['caption'] != null
                        ? Text(
                            stories[currentIndex]['caption'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )
                        : const SizedBox.shrink(),
                  ),
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
                                  ? isLightTheme
                                      ? Colors.black
                                      : Colors.white
                                  : isLightTheme
                                      ? Colors.grey[500]
                                      : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  stories[currentIndex]['nickname'] != nickname
                      ? Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: isLightTheme
                                ? Colors.grey[800]
                                : Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Like button
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.favorite_border,
                                    color: isLightTheme
                                        ? Colors.white
                                        : Colors.white,
                                  ),
                                ),
                                // Reply Text Field in the middle
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: isLightTheme
                                          ? Colors.grey[100]
                                          : Colors.grey[900],
                                    ),
                                    child: TextField(
                                      controller: replyController,
                                      style: TextStyle(
                                          color: isLightTheme
                                              ? Colors.black
                                              : Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Reply...',
                                        hintStyle: TextStyle(
                                            color: isLightTheme
                                                ? Colors.black
                                                : Colors.white),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 1, horizontal: 15),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(60)),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Share button
                                IconButton(
                                  onPressed: () {
                                    if (replyController.text.isNotEmpty) {
                                      sendReply(
                                          stories[currentIndex]['username']);
                                    }
                                  },
                                  icon: const Icon(Icons.send,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Positioned(
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: SizedBox.shrink()),
                ],
              ),
            ),
    );
  }
}
