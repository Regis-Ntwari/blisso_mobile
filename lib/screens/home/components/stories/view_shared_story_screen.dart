import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/services/stories/get_one_story_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewSharedStoryScreen extends ConsumerStatefulWidget {
  final int id;
  const ViewSharedStoryScreen({super.key, required this.id});

  @override
  ConsumerState<ViewSharedStoryScreen> createState() =>
      _ViewSharedStoryScreenState();
}

class _ViewSharedStoryScreenState
    extends ConsumerState<ViewSharedStoryScreen> {
  VideoPlayerController? _videoController;
  Map<String, dynamic>? _story;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

    _fetchAndLoadStory();
    });
  }

  Future<void> _fetchAndLoadStory() async {
    final storyRef = ref.read(getOneStoryProviderImpl.notifier);
    await storyRef.getOneStory(widget.id);
    setState(() {
      _story = ref.read(getOneStoryProviderImpl).data;
      _loading = false;
    });

    if (_story!['post_type'] == 'VIDEO') {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(_story!['post_file_url']),
      )
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
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
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: GlobalColors.primaryColor,
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: _story!['post_type'] == 'IMAGE'
                  ? CachedNetworkImage(
                      imageUrl: _story!['post_file_url'],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          color: GlobalColors.primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : _videoController != null &&
                          _videoController!.value.isInitialized
                      ? VideoPlayer(_videoController!)
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
                icon: Icon(Icons.close, color: isLightTheme ? Colors.black : Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            _story!['caption'] != null || _story!['caption'] != '' ? Positioned(bottom: 50, left: MediaQuery.sizeOf(context).width / 2 - 50 , child: ExpandableTextComponent(text: _story!['caption'])) : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
