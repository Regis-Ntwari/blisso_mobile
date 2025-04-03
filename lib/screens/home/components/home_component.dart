import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:blisso_mobile/screens/home/components/short_status_component.dart';
import 'package:blisso_mobile/services/stories/stories_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeComponent extends ConsumerStatefulWidget {
  final List<dynamic>? profiles;
  final Function refetch;
  const HomeComponent(
      {super.key, required this.profiles, required this.refetch});

  @override
  ConsumerState<HomeComponent> createState() => _HomeComponentState();
}

class _HomeComponentState extends ConsumerState<HomeComponent> {
  final ScrollController _scrollController = ScrollController();

  dynamic statuses;

  Future<void> getStatuses() async {
    final storiesRef = ref.read(storiesServiceProviderImpl.notifier);
    await storiesRef.getStories();

    final stories = ref.read(storiesServiceProviderImpl);

    Map<String, List<dynamic>> fetchedStories = {};

    if (!stories.data['my_stories']['stories'].isEmpty) {
      fetchedStories[stories.data['my_stories']['nickname']] =
          stories.data['my_stories']['stories'];
    }
    for (var other in stories.data['others_stories']) {
      fetchedStories[other['nickname']] = other['stories'];
    }

    setState(() {
      statuses = fetchedStories;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return widget.profiles == null || statuses == null
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
