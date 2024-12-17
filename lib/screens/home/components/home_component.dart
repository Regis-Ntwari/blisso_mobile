import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
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
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) => PostCardComponent(
                  profile: widget.profiles![index],
                ),
                itemCount: widget.profiles!.length,
              ),
            ),
          );
  }
}
