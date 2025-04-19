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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storiesServiceProviderImpl.notifier).getStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final statusRef = ref.watch(storiesServiceProviderImpl);
    Map<String, List<dynamic>> fetchedStories = {};

    if (!statusRef.isLoading && statusRef.data != null) {
      if (!statusRef.data['my_stories']['stories'].isEmpty) {
        fetchedStories[statusRef.data['my_stories']['nickname']] =
            statusRef.data['my_stories']['stories'];
      }
      for (var other in statusRef.data['others_stories']) {
        fetchedStories[other['nickname']] = other['stories'];
      }
    }

    return widget.profiles == null || statusRef.isLoading
        ? const LoadingScreen()
        : RefreshIndicator(
            backgroundColor: GlobalColors.primaryColor,
            color: GlobalColors.whiteColor,
            onRefresh: () async {
              await widget.refetch();
              await ref.read(storiesServiceProviderImpl.notifier).getStories();
            },
            child: SingleChildScrollView(
              child: Container(
                height: height * 0.9,
                color: isLightTheme ? Colors.white : Colors.black,
                child: Column(
                  children: [
                    ShortStatusComponent(statuses: fetchedStories),
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
            ),
          );
  }
}
